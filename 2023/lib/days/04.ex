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

  def part2() do
    cards =
      AdventOfCode2023.get_lines("4")
      |> Enum.map(fn line ->
        %{card: card, winning_numbers: winning_numbers, numbers: numbers} =
          parse_scratchcard(line)

        nb_winning_numbers =
          numbers
          |> Enum.filter(&is_winning_numbers(&1, winning_numbers))
          |> length()

        {card, nb_winning_numbers}
      end)

    Day04.Part2.cards_to_ets(cards)

    Stream.map(cards, &compute_nb_copies_cards/1)
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

  def compute_nb_copies_cards(card) do
    nb_copies =
      stream_card_copies(card)
      |> Stream.map(&compute_nb_copies_cards(&1))
      |> Enum.sum()

    1 + nb_copies
  end

  def stream_card_copies({_, 0}), do: []

  def stream_card_copies({card_nb, nb_copies}) do
    (card_nb + 1)..(card_nb + nb_copies)
    |> Stream.map(&Day04.Part2.get_card/1)
  end
end

defmodule Day04.Part2 do
  @table :cards

  def cards_to_ets(cards) do
    :ets.delete(@table)
    :ets.new(@table, [:named_table, :set])

    :ets.insert(@table, cards)
  end

  def get_card(nb), do: :ets.lookup(@table, nb) |> hd()
end
