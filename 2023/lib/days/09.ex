defmodule Day09 do
  def part1() do
    AdventOfCode2023.get_lines("9")
    |> parse_report()
    |> Stream.map(&predict_next_step/1)
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

  def predict_next_step(sequence) do
    if Enum.all?(sequence, &Kernel.==(&1, 0)) do
      0
    else
      intervals = sequence |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)

      next_step = predict_next_step(intervals)

      List.last(sequence) + next_step
    end
  end
end
