defmodule Day04 do
  def part1() do
    AdventOfCode2023.get_lines("4")
    |> Enum.map(fn line ->
      %{winning_numbers: winning_numbers, numbers: numbers} = parse_scratchcard(line)

      numbers
      |> Enum.filter(&is_winning_numbers(&1, winning_numbers))
      |> compute_card_value()
    end)
    |> Enum.sum()
  end

  def parse_scratchcard(line) do
    "Card " <> line = line
    [card_nb, line] = String.split(line, ":")
    card_nb = card_nb |> String.replace_leading(" ", "") |> String.to_integer()

    [winning_numbers, numbers] = line |> String.split("|") |> Enum.map(&parse_numbers/1)

    %{card: card_nb, winning_numbers: winning_numbers, numbers: numbers}
  end

  def parse_numbers(numbers) do
    numbers
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def is_winning_numbers(nb, winning_numbers), do: nb in winning_numbers

  def compute_card_value(nb),
    do:
      List.foldl(nb, 0, fn
        _, 0 -> 1
        _, acc -> acc + acc
      end)
end
