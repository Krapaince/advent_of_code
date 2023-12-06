defmodule Day06 do
  def part1() do
    AdventOfCode2023.get_lines("6")
    |> parse_input()
    |> run()
  end

  def part2() do
    AdventOfCode2023.get("6")
    |> String.replace(" ", "")
    |> String.split("\n", trim: true)
    |> parse_input()
    |> run()
  end

  def run(races) do
    races
    |> Enum.map(fn {time, record_distance} ->
      compute_every_possible_race(time)
      |> Stream.reject(fn race_distance -> race_distance <= record_distance end)
      |> Enum.count()
    end)
    |> Enum.reduce(&Kernel.*/2)
  end

  def parse_input(content) do
    content
    |> Enum.map(fn line ->
      line
      |> String.split(":")
      |> Enum.at(1)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  def compute_every_possible_race(time) do
    0..time |> Stream.map(fn push_time -> push_time * (time - push_time) end)
  end
end
