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

  def keep_only_digit(str), do: String.replace(str, ~r/[^0-9]/, "")

  def to_calibration_value(str) do
    "#{String.first(str)}#{String.last(str)}" |> String.to_integer()
  end
end
