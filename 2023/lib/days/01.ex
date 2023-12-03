defmodule Day01 do
  def part1() do
    AdventOfCode2023.get_lines("1")
    |> Enum.map(fn line ->
      line
      |> keep_only_digit()
      |> to_calibration_value()
    end)
    |> Enum.sum()
  end

  def part2() do
    AdventOfCode2023.get_lines("1")
    |> Enum.map(fn line ->
      line
      |> replace_text_digit()
      |> keep_only_digit()
      |> to_calibration_value()
    end)
    |> Enum.sum()
  end

  def replace_text_digit(line) do
    ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    |> Enum.reduce(line, fn pattern, line ->
      line
      |> String.replace(
        pattern,
        fn
          "one" -> "o1e"
          "two" -> "t2o"
          "three" -> "t3e"
          "four" -> "f4r"
          "five" -> "f5e"
          "six" -> "s6x"
          "seven" -> "s7n"
          "eight" -> "e8t"
          "nine" -> "n9e"
        end
      )
    end)
  end

  def keep_only_digit(str), do: String.replace(str, ~r/[^0-9]/, "")

  def to_calibration_value(str) do
    "#{String.first(str)}#{String.last(str)}" |> String.to_integer()
  end
end
