defmodule Day10 do
  alias Day10.{Coordinate, Tiles}

  def part1() do
    tiles =
      AdventOfCode2023.get_lines("10")
      |> parse_tiles()

    starting_tile = find_starting_tile(tiles)

    stream_pipe_tiles(starting_tile, tiles)
    |> Enum.count()
    |> div(2)
  end

  def parse_tiles(content) do
    content
    |> Stream.with_index()
    |> Stream.flat_map(fn {lines, y} ->
      lines
      |> String.to_charlist()
      |> Enum.with_index(fn cell, x -> {{x, y}, cell} end)
    end)
    |> Map.new()
  end

  def find_starting_tile(tiles) do
    tiles
    |> Enum.find_value(fn
      {coord, ?S} -> coord
      _ -> nil
    end)
  end

  def stream_pipe_tiles(starting_tile, tiles) do
    neighbour = stream_connected_pipes(starting_tile, tiles) |> Enum.take(1) |> List.first()

    Stream.unfold(
      [neighbour, starting_tile],
      fn
        [current, previous] ->
          next = get_next_tile(current, previous, tiles)

          unless next == starting_tile do
            {previous, [next, current]}
          else
            {previous, [current]}
          end

        [current] ->
          {current, nil}

        nil ->
          nil
      end
    )
  end

  def get_next_tile(current_tile, previous_tile, tiles) do
    current_pipe = Tiles.at(tiles, current_tile)

    get_connected_pipes(current_tile, current_pipe)
    |> Enum.filter(&Kernel.!=(&1, previous_tile))
    |> List.first()
  end

  def get_connected_pipes(coord, ?|), do: [Coordinate.south(coord), Coordinate.north(coord)]
  def get_connected_pipes(coord, ?-), do: [Coordinate.west(coord), Coordinate.east(coord)]
  def get_connected_pipes(coord, ?L), do: [Coordinate.north(coord), Coordinate.east(coord)]
  def get_connected_pipes(coord, ?J), do: [Coordinate.north(coord), Coordinate.west(coord)]
  def get_connected_pipes(coord, ?7), do: [Coordinate.south(coord), Coordinate.west(coord)]
  def get_connected_pipes(coord, ?F), do: [Coordinate.south(coord), Coordinate.east(coord)]

  def stream_connected_pipes(coord, tiles) do
    [
      {Coordinate.west(coord), [?-, ?L, ?F]},
      {Coordinate.north(coord), [?|, ?7, ?F]},
      {Coordinate.east(coord), [?-, ?J, ?7]},
      {Coordinate.south(coord), [?|, ?L, ?J]}
    ]
    |> Stream.flat_map(fn {neighbour, connectable_pipes} ->
      pipe = Tiles.at(tiles, neighbour)

      maybe_neighbour = if pipe in connectable_pipes, do: neighbour

      List.wrap(maybe_neighbour)
    end)
  end
end

defmodule Day10.Tiles do
  def at(tiles, coord), do: Map.get(tiles, coord)
end

defmodule Day10.Coordinate do
  def south(coord), do: add(coord, {0, 1})
  def north(coord), do: add(coord, {0, -1})
  def west(coord), do: add(coord, {-1, 0})
  def east(coord), do: add(coord, {1, 0})

  def add(coord1, coord2) do
    {x1, y1} = coord1
    {x2, y2} = coord2

    {x1 + x2, y1 + y2}
  end
end
