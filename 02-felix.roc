app "02-felix"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main =
    path = "02-felix.txt"

    task =
        text <- File.readUtf8 (Path.fromStr path) |> Task.await

        output1 =
            when part1 text is
                Ok answer -> "Answer: \(Num.toStr answer)"
                Err (InvalidLine line) -> "Error: invalid line: '\(line)'"
        output2 =
            when part2 text is
                Ok answer -> "Answer: \(Num.toStr answer)"
                Err (InvalidLine line) -> "Error: invalid line: '\(line)'"

        Stdout.line
            """
            Part 1) \(output1)
            Part 2) \(output2)
            """

    Task.onErr task \_ -> Stdout.line "error: failed to read file \(path)"

part1 : Str -> Result Nat [InvalidLine Str]
part1 = \text ->
    text
    |> maxCountperGame
    |> Result.map \games ->
        games
        |> List.map
            \(id, { red, green, blue }) ->
                if red <= 12 && green <= 13 && blue <= 14 then
                    id
                else
                    0
        |> List.sum

part2 : Str -> Result Nat [InvalidLine Str]
part2 = \text ->
    text
    |> maxCountperGame
    |> Result.map \games ->
        games
        |> List.map
            \(_, { red, green, blue }) -> red * green * blue
        |> List.sum

maxCountperGame : Str
    -> Result
        (List (Nat, { red : Nat, green : Nat, blue : Nat }))
        [InvalidLine Str]
maxCountperGame = \text ->
    text
    |> Str.trim
    |> Str.split "\n"
    |> List.mapTry \line ->
        parseSets = \sets ->
            sets
            |> Str.split "; "
            |> List.joinMap \set -> set |> Str.split ", "
            |> List.walkTry
                { red: 0, green: 0, blue: 0 }
                \acc, item ->
                    when item |> Str.splitFirst " " is
                        Ok { before, after } ->
                            when (Str.toNat before, after) is
                                (Ok count, "red") -> Ok { acc & red: Num.max acc.red count }
                                (Ok count, "green") -> Ok { acc & green: Num.max acc.green count }
                                (Ok count, "blue") -> Ok { acc & blue: Num.max acc.blue count }
                                (_, _) -> Err (InvalidLine line)

                        Err _ -> Err (InvalidLine line)

        when line |> Str.splitFirst ": " is
            Ok { before, after } ->
                when before |> Str.replaceFirst "Game " "" |> Str.toNat is
                    Ok id -> parseSets after |> Result.map \game -> (id, game)
                    Err _ -> Err (InvalidLine line)

            Err NotFound -> Err (InvalidLine line)
