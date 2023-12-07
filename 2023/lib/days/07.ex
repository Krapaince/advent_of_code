defmodule Day07 do
  def part1(), do: run()
  def part2(), do: run(joker: true)

  def run(opts \\ []) do
    AdventOfCode2023.get("7")
    |> then(fn content ->
      if Keyword.get(opts, :joker, false),
        do: String.replace(content, "J", "*"),
        else: content
    end)
    |> String.split("\n", trim: true)
    |> parse_hands(opts)
    |> sort_camel_cards()
    |> enrich_sorted_cards_with_rank()
    |> compute_total()
  end

  def parse_hands(content, opts) do
    content
    |> Enum.map(fn line ->
      [raw_hand, bid] = String.split(line, " ")

      hand = parse_hand(raw_hand)

      hand_type =
        if Keyword.get(opts, :joker, false),
          do: hand_to_type_with_joker(raw_hand),
          else: hand_to_type(raw_hand)

      type_strengh = type_to_strengh(hand_type)

      bid = String.to_integer(bid)

      %{
        raw_hand: raw_hand,
        hand: hand,
        type: hand_type,
        type_strengh: type_strengh,
        bid: bid
      }
    end)
  end

  def parse_hand(hand) do
    hand
    |> String.to_charlist()
    |> Enum.map(&card_to_number/1)
  end

  def card_to_number(?*), do: 0
  def card_to_number(?2), do: 1
  def card_to_number(?3), do: 2
  def card_to_number(?4), do: 3
  def card_to_number(?5), do: 4
  def card_to_number(?6), do: 5
  def card_to_number(?7), do: 6
  def card_to_number(?8), do: 7
  def card_to_number(?9), do: 8
  def card_to_number(?T), do: 9
  def card_to_number(?J), do: 10
  def card_to_number(?Q), do: 11
  def card_to_number(?K), do: 12
  def card_to_number(?A), do: 13

  def hand_to_type_with_joker("*****"), do: :five

  def hand_to_type_with_joker(raw_hand) do
    nb_jokers = raw_hand |> String.to_charlist() |> Enum.frequencies() |> Map.get(?*, 0)
    hand_type_without_joker = raw_hand |> String.replace("*", "") |> hand_to_type()

    case nb_jokers do
      0 ->
        hand_to_type(raw_hand)

      1 ->
        case hand_type_without_joker do
          :four -> :five
          :three -> :four
          :two_pairs -> :full_house
          :pair -> :three
          :high_card -> :pair
        end

      2 ->
        case hand_type_without_joker do
          :three -> :five
          :pair -> :four
          :high_card -> :three
        end

      3 ->
        case hand_type_without_joker do
          :high_card -> :four
          :pair -> :five
        end

      4 ->
        :five
    end
  end

  def hand_to_type(hand) do
    nb_same_types =
      hand
      |> String.to_charlist()
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)

    case nb_same_types do
      [5] -> :five
      [4 | _] -> :four
      [3, 2] -> :full_house
      [3 | _] -> :three
      [2, 2 | _] -> :two_pairs
      [2 | _] -> :pair
      _ -> :high_card
    end
  end

  def type_to_strengh(:high_card), do: 0
  def type_to_strengh(:pair), do: 1
  def type_to_strengh(:two_pairs), do: 2
  def type_to_strengh(:three), do: 3
  def type_to_strengh(:full_house), do: 4
  def type_to_strengh(:four), do: 5
  def type_to_strengh(:five), do: 6

  def sort_camel_cards(camel_cards) do
    camel_cards
    |> Enum.sort(&do_sort_camel_cards/2)
  end

  def do_sort_camel_cards(%{type_strengh: strength} = cc1, %{type_strengh: strength} = cc2) do
    Stream.zip(cc1.hand, cc2.hand)
    |> Stream.reject(fn {card1, card2} -> card1 == card2 end)
    |> Stream.map(fn {card1, card2} -> card1 < card2 end)
    |> Enum.take(1)
    |> List.first()
    |> then(fn
      nil -> true
      sort -> sort
    end)
  end

  def do_sort_camel_cards(%{type_strengh: cc1_strength}, %{type_strengh: cc2_stength}),
    do: cc1_strength < cc2_stength

  def enrich_sorted_cards_with_rank(camel_cards) do
    camel_cards
    |> Enum.with_index(&Map.put(&1, :rank, &2 + 1))
  end

  def compute_total(camel_cards) do
    camel_cards
    |> Enum.map(fn card -> card.rank * card.bid end)
    |> Enum.sum()
  end
end
