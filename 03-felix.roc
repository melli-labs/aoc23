# NOTE: this solution somewhat quick & dirty and not as polished as other solutions
app "03-felix"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main =
    path = "03-example1.txt"

    task =
        text <- File.readUtf8 (Path.fromStr path) |> Task.await

        output1 =
            when part1 text is
                Ok answer -> "Part 1) Answer: \(Num.toStr answer)"
                Err HardProgrammingError -> "Part 1) Error: invalid input"

        Str.joinWith
            [
                output1,
            ]
            "\n"
        |> Stdout.line

    Task.onErr task \_ -> Stdout.line "error: failed to read file \(path)"

part1 : Str -> Result Nat [HardProgrammingError]
part1 = \text ->
    schematic =
        text
        |> Str.trim
        |> Str.split "\n"
        |> List.map Str.graphemes

    getNeighbours : Nat, Nat -> List Str
    getNeighbours = \i, j ->
        get2d = \u, v -> schematic
            |> List.get u
            |> Result.try \sub -> sub |> List.get v

        i2 = Num.toI32 i
        j2 = Num.toI32 j

        [
            (i2 - 1, j2 - 1),
            (i2 - 1, j2),
            (i2 - 1, j2 + 1),
            (i2, j2 - 1),
            (i2, j2 + 1),
            (i2 + 1, j2 - 1),
            (i2 + 1, j2),
            (i2 + 1, j2 + 1),
        ]
        |> List.keepOks \(k, l) ->

            if
                k >= 0 && l >= 0
            then
                Ok (Num.toNat k, Num.toNat l)
            else
                Err Foo
        |> List.keepOks \(k, l) -> get2d k l

    schematic
    |> List.mapWithIndex \line, i ->
        reset = \{ found, candidate } ->

            nextFound =
                when candidate is
                    WithNeigbour x -> found |> List.append x
                    _ -> found

            {
                found: nextFound,
                candidate: None,
            }

        push = \{ found, candidate }, point, neigbours ->
            hasNeigbour =
                neigbours
                |> List.any \char -> !((char |> Str.toNat |> Result.isOk) || (char == "."))
            nextCandidate =
                when candidate is
                    WithNeigbour x -> WithNeigbour (x |> Str.concat point)
                    NoNeigbour x ->
                        if hasNeigbour then
                            WithNeigbour (x |> Str.concat point)
                        else
                            NoNeigbour (x |> Str.concat point)

                    None ->
                        if hasNeigbour then
                            WithNeigbour point
                        else
                            NoNeigbour point
            { found, candidate: nextCandidate }

        line
        |> List.walkWithIndex
            { found: [], candidate: None }
            \acc, point, j ->

                neigbours = getNeighbours i j

                if point |> Str.toNat |> Result.isOk then
                    push acc point neigbours
                else
                    reset acc
        |> reset
        |> .found
        |> List.mapTry Str.toNat
        |> Result.mapErr \_ -> HardProgrammingError
        |> Result.map List.sum
    |> List.mapTry \x -> x
    |> Result.map List.sum

