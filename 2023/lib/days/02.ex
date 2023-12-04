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
      Map.get(set, :red, 0) <= red and
        Map.get(set, :green, 0) <= green and
        Map.get(set, :blue, 0) <= blue
    end)
  end

  def part2() do
    AdventOfCode2023.get_lines("2")
    |> Day02.Parse.game()
    |> Stream.map(fn {id, sets} ->
      Enum.reduce(sets, &Map.merge(&1, &2, fn _, v1, v2 -> max(v1, v2) end))
      |> Map.values()
      |> tap(fn colors ->
        if Enum.any?(colors, &Kernel.==(&1, 0)), do: IO.puts("Game #{id}")
      end)
      |> Enum.reduce(&Kernel.*/2)
    end)
    |> Enum.sum()
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

  defp game_set(set), do: String.split(set, ",") |> Map.new(&draw/1)

  defp draw(draw) do
    [nb, color] = String.split(draw, " ", trim: true)
    color = String.to_atom(color)
    nb = String.to_integer(nb)

    {color, nb}
  end
end
