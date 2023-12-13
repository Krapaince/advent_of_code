defmodule Day11 do
  def part1() do
    content = AdventOfCode2023.get_lines("11")

    empty_spaces = find_empty_spaces(content)

    find_galaxies(content)
    |> Enum.map(&expand_galaxy(&1, empty_spaces))
    |> make_galaxy_pairs()
    |> Enum.map(fn {g1, g2} -> compute_distance(g1, g2) end)
    |> Enum.sum()
  end

  def find_empty_spaces(content) do
    horizontal_empty_spaces =
      content
      |> Stream.with_index()
      |> Stream.filter(fn {line, _} -> String.match?(line, ~r/^\.*$/) end)
      |> Stream.map(fn {_, y} -> y end)
      |> Enum.to_list()

    vertical_empty_spaces =
      content
      |> Stream.flat_map(fn line ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
      end)
      |> Enum.group_by(fn {_, x} -> x end, fn {cell, _} -> cell end)
      |> Stream.filter(fn {_, cells} -> Enum.all?(cells, fn cell -> cell == ?. end) end)
      |> Enum.map(fn {x, _} -> x end)

    {horizontal_empty_spaces, vertical_empty_spaces}
  end

  def find_galaxies(content) do
    content
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.to_charlist()
      |> Stream.with_index()
      |> Stream.filter(fn {maybe_galaxy, _} -> maybe_galaxy == ?# end)
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
    |> Enum.to_list()
  end

  def expand_galaxy(galaxy, empty_spaces) do
    {xg, yg} = galaxy
    {horizontal_empty_spaces, vertical_empty_spaces} = empty_spaces

    nb_horizontal_empty_spaces =
      horizontal_empty_spaces
      |> Stream.filter(fn y -> yg > y end)
      |> Enum.count()

    nb_vertical_empty_spaces =
      vertical_empty_spaces
      |> Stream.filter(fn x -> xg > x end)
      |> Enum.count()

    {
      xg + nb_vertical_empty_spaces,
      yg + nb_horizontal_empty_spaces
    }
  end

  def make_galaxy_pairs(galaxies) do
    galaxies
    |> Stream.with_index(1)
    |> Stream.flat_map(fn {galaxy1, i} ->
      galaxies
      |> Stream.drop(i)
      |> Enum.map(fn galaxy2 -> {galaxy1, galaxy2} end)
    end)
  end

  def compute_distance(point1, point2) do
    {x1, y1} = point1
    {x2, y2} = point2

    abs(x2 - x1) + abs(y2 - y1)
  end
end
