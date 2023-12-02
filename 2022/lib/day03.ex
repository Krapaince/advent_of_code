defmodule Day03 do
  def solve1() do
    Adventcode.get_input_content(3)
    |> String.split("\n")
    |> Enum.map(fn line ->
      len = line |> String.length() |> Kernel./(2) |> round()

      {first_compartment, second_compartment} = line |> String.split_at(len)

      first_compartment = first_compartment |> compartment_to_mapset()
      second_compartment = second_compartment |> compartment_to_mapset()

      {first_compartment, second_compartment}
    end)
    |> Enum.map(fn {first_compartment, second_compartment} ->
      MapSet.intersection(first_compartment, second_compartment)
      |> MapSet.to_list()
      |> Enum.map(&char_to_priority/1)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def solve2() do
    Adventcode.get_input_content(3)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> line |> to_charlist() |> MapSet.new() end)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [c1, c2, c3] ->
      MapSet.intersection(c1, c2)
      |> MapSet.intersection(c3)
      |> MapSet.to_list()
      |> List.first()
      |> char_to_priority()
    end)
    |> Enum.sum()
  end

  def parse_input() do
  end

  def compartment_to_mapset(compartment) do
    compartment
    |> to_charlist()
    |> MapSet.new()
  end

  def char_to_priority(c) do
    priority_offset = 1
    maj_offset = 26

    priority =
      cond do
        ?a <= c && c <= ?z -> c - ?a
        ?A <= c && c <= ?Z -> c - ?A + maj_offset
        true -> 0
      end

    priority + priority_offset
  end
end
