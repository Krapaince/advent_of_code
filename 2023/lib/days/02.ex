defmodule Day02 do
  def part1() do
    AdventOfCode2023.get_lines("2")
    |> Day02.Parse.game()
    |> Stream.flat_map(fn game ->
      if is_game_possible(game) do
        elem(game, 0)
      end
      |> List.wrap()
    end)
    |> Enum.sum()
  end

  def is_game_possible(game) do
    red = 12
    green = 13
    blue = 14

    {_, sets} = game

    sets
    |> Enum.all?(fn set ->
      set.red <= red and set.green <= green and set.blue <= blue
    end)
  end
end

defmodule Day02.Parse do
  def game(lines) do
    lines
    |> Stream.map(fn line ->
      ["Game " <> id, raw_sets] = String.split(line, ":")
      id = String.to_integer(id)

      sets = game_sets(raw_sets)

      {id, sets}
    end)
  end

  defp game_sets(sets) do
    sets |> String.split(";") |> Enum.map(&game_set/1)
  end

  defp game_set(set) do
    default_set = %{red: 0, green: 0, blue: 0}

    set = String.split(set, ",") |> Map.new(&draw/1)

    Map.merge(default_set, set)
  end

  defp draw(draw) do
    [nb, color] = String.split(draw, " ", trim: true)
    color = String.to_atom(color)
    nb = String.to_integer(nb)

    {color, nb}
  end
end
