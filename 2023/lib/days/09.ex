defmodule Day09 do
  def part1(), do: run(:forward)
  def part2(), do: run(:backward)

  def run(mode) do
    AdventOfCode2023.get_lines("9")
    |> parse_report()
    |> Stream.map(&predict_step(&1, mode))
    |> Enum.sum()
  end

  def parse_report(content) do
    content
    |> Stream.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def predict_step(sequence, direction) do
    if Enum.all?(sequence, &Kernel.==(&1, 0)) do
      0
    else
      intervals = sequence |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)

      next_step = predict_step(intervals, direction)

      case direction do
        :forward ->
          List.last(sequence) + next_step

        :backward ->
          hd(sequence) - next_step
      end
    end
  end
end
