defmodule Day04 do
  def solve1() do
    parse_input()
    |> Enum.filter(fn [fp, sp] ->
      are_numbers_in_range?(fp, sp) || are_numbers_in_range?(sp, fp)
    end)
    |> Enum.count()
  end

  def solve2() do
    parse_input()
    |> Enum.filter(fn [fp, sp] ->
      is_one_number_in_range?(fp, sp) || is_one_number_in_range?(sp, fp)
    end)
    |> Enum.count()
  end

  def parse_input() do
    Adventcode.get_input_content(4)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn pair ->
        pair |> String.split("-") |> Enum.map(&String.to_integer/1)
      end)
    end)
  end

  def are_numbers_in_range?(numbers, [a, b]) do
    range = a..b

    numbers
    |> Enum.map(&is_number_in_range(&1, range))
    |> Enum.all?()
  end

  def is_one_number_in_range?(numbers, [a, b]) do
    range = a..b

    numbers
    |> Enum.map(&is_number_in_range(&1, range))
    |> Enum.any?()
  end

  def is_number_in_range(number, range), do: number in range
end
