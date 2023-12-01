app "00-felix"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }

    imports [pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main =
    path = "01-felix.txt"

    task =
        text <- File.readUtf8 (Path.fromStr path) |> Task.await

        output1 =
            when part1 text is
                Ok answer -> "Part 1) Answer: \(Num.toStr answer)"
                Err NoNumber -> "Part 1) Error: Not all lines contain a number!"

        output2v1 =
            when part2V1 text is
                Ok answer -> "Part 2v1) Answer: \(Num.toStr answer)"
                Err NoNumber -> "Part 2v1) Error: Not all lines contain a number!"

        output2v2 =
            when part2V2 text is
                Ok answer -> "Part 2v2) Answer: \(Num.toStr answer)"
                Err NoNumber -> "Part 2v2) Error: Not all lines contain a number!"

        Str.joinWith
            [
                output1,
                output2v1,
                output2v2,
            ]
            "\n"
        |> Stdout.line

    Task.onErr task \_ -> Stdout.line "error: failed to read file \(path)"

part1 : Str -> Result I32 [NoNumber]
part1 = \text ->
    text
    |> Str.trim
    |> Str.split "\n"
    |> List.mapTry \line ->
        numbers =
            line
            |> Str.graphemes
            |> List.keepOks Str.toI32
        when (List.first numbers, List.last numbers) is
            (Ok first, Ok last) -> Ok (10 * first + last)
            _ -> Err NoNumber
    |> Result.map List.sum

part2V1 : Str -> Result Nat [NoNumber]
part2V1 = \text ->
    words = [
        ("one", "o1e"),
        ("two", "t2o"),
        ("three", "t3e"),
        ("four", "f4r"),
        ("five", "f5e"),
        ("six", "s6x"),
        ("seven", "s7n"),
        ("eight", "e8t"),
        ("nine", "n9e"),
    ]
    sanatized =
        words
        |> List.walk text \acc, (a, b) -> acc |> Str.replaceEach a b

    sanatized
    |> Str.trim
    |> Str.split "\n"
    |> List.mapTry \line ->
        numbers =
            line
            |> Str.graphemes
            |> List.keepOks Str.toNat
        when (List.first numbers, List.last numbers) is
            (Ok first, Ok last) -> Ok (10 * first + last)
            _ -> Err NoNumber
    |> Result.map List.sum

part2V2 : Str -> Result Nat [NoNumber]
part2V2 = \text ->
    words = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    text
    |> Str.trim
    |> Str.split "\n"
    |> List.mapTry \line ->
        numbers =
            line
            |> Str.graphemes
            |> List.walk
                { current: "", values: [] }
                \{ current, values }, char ->
                    next = current |> Str.concat char
                    maybeDigit = char |> Str.toNat
                    nCandidates = Str.countGraphemes next
                    candidates =
                        List.range { start: At 0, end: Length nCandidates }
                        |> List.map \start ->
                            next
                            |> Str.graphemes
                            |> List.sublist { start, len: nCandidates - start }
                            |> Str.joinWith ""

                    maybeHit =
                        candidates
                        |> List.keepOks \candidate ->
                            words |> List.findFirstIndex \word -> word == candidate
                        |> List.first

                    maybeCandidate =
                        candidates
                        |> List.findFirst \candidate ->
                            words |> List.any \word -> Str.startsWith word candidate

                    when maybeDigit is
                        Ok number ->
                            {
                                current: "",
                                values: values |> List.append number,
                            }

                        Err InvalidNumStr ->
                            when maybeHit is
                                Ok number ->
                                    {
                                        current: next,
                                        values: values |> List.append (number + 1),
                                    }

                                Err ListWasEmpty ->
                                    when maybeCandidate is
                                        Ok candidate ->
                                            {
                                                current: candidate,
                                                values: values,
                                            }

                                        Err _ ->
                                            {
                                                current: "",
                                                values: values,
                                            }
            |> .values

        when (List.first numbers, List.last numbers) is
            (Ok first, Ok last) -> Ok (10 * first + last)
            _ -> Err NoNumber
    |> Result.map List.sum
