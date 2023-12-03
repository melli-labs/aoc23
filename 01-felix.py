def part1(text: str) -> int:
    def process_line(line: str):
        numbers = list(filter(str.isdigit, line))
        return int(numbers[0] + numbers[-1])

    return sum(map(process_line, text.strip().splitlines()))


def part2(text: str) -> int:
    from functools import reduce

    numbers = [
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

    sanatized = reduce(
        lambda text, item: text.replace(item[0], item[1]),
        numbers,
        text,
    )
    return part1(sanatized)


if __name__ == "__main__":
    from pathlib import Path

    text1 = Path("01-example1.txt").read_text()
    answer1 = part1(text1)
    print(f"Part 1) Answer: {answer1}")

    text2 = Path("01-example2.txt").read_text()
    answer2 = part2(text2)
    print(f"Part 2) Answer: {answer2}")
