defmodule Day10 do
  require Integer

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

  def part2() do
    tiles =
      AdventOfCode2023.get_lines("10")
      |> parse_tiles()

    starting_tile = find_starting_tile(tiles)

    pipe_tiles =
      stream_pipe_tiles(starting_tile, tiles)
      |> Enum.to_list()

    pipe_vertices =
      stream_vertices(pipe_tiles)
      |> Enum.to_list()

    tiles
    |> Stream.filter(fn {coord, _} ->
      coord not in pipe_tiles and is_tile_inside_pipe(coord, pipe_vertices)
    end)
    |> Enum.count()
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

  def stream_vertices(pipe_tiles) do
    corner_tile = find_first_pipe_corner_tile(pipe_tiles)
    corner_tile_idx = Enum.find_index(pipe_tiles, &Kernel.==(&1, corner_tile))

    [
      Stream.drop(pipe_tiles, corner_tile_idx),
      pipe_tiles |> Stream.take(corner_tile_idx + 1)
    ]
    |> Stream.concat()
    |> Stream.chunk_while(
      nil,
      fn
        current, nil ->
          {:cont, [current]}

        current, [prev] ->
          {:cont, {vertice_orientation(prev, current), [current, prev]}}

        current, {orientation, [prev | _] = vertice_tiles} = vertice ->
          case vertice_orientation(prev, current) do
            ^orientation -> {:cont, {orientation, [current | vertice_tiles]}}
            orientation -> {:cont, vertice, {orientation, [current, prev]}}
          end
      end,
      fn vertice -> {:cont, vertice, nil} end
    )
    |> Stream.map(fn vertice ->
      {orientation, tiles} = vertice

      a = List.first(tiles)
      b = List.last(tiles)

      {orientation, Enum.sort([a, b])}
    end)
  end

  def find_first_pipe_corner_tile(pipe_tiles) do
    pipe_tiles
    |> Stream.chunk_every(3, 1)
    |> Stream.map(&Enum.sort/1)
    |> Enum.find_value(fn
      [{x, y1}, {x, y} = corner, {x1, y}] when x < x1 and y > y1 ->
        # |
        # +-
        corner

      [{x1, y}, {x, y} = corner, {x, y1}] when x > x1 and y < y1 ->
        # -+
        #  |
        corner

      [{x, y1}, {x1, y}, {x, y} = corner] when x > x1 and y > y1 ->
        #  |
        # -+
        corner

      [{x, y} = corner, {x1, y}, {x, y1}] when x < x1 and y < y1 ->
        # +-
        # |
        corner

      _ ->
        nil
    end)
  end

  def vertice_orientation(coord1, coord2) do
    case Day10.Coordinate.sub(coord1, coord2) do
      {0, y} when y != 0 -> :vertical
      {x, 0} when x != 0 -> :horizontal
    end
  end

  def is_tile_inside_pipe(tile, pipe_vertices) do
    {xt, yt} = tile

    {vertical_vertices, horizontal_vertices} =
      pipe_vertices
      |> Stream.filter(fn
        {:horizontal, [{xv, yv}, _]} ->
          xt < xv and yt == yv

        {:vertical, [{xv, yv1}, {_, yv2}]} ->
          xt < xv and yt >= yv1 and yt <= yv2
      end)
      |> Enum.split_with(fn {orientation, _} -> orientation == :vertical end)

    horizontal_vertices =
      horizontal_vertices
      |> Enum.filter(&should_horizontal_vertice_count(&1, vertical_vertices))

    (horizontal_vertices ++ vertical_vertices)
    |> length()
    |> Integer.is_odd()
  end

  def should_horizontal_vertice_count(vertice, vertical_vertices) do
    {_, coords} = vertice
    [{_, y}, _] = coords

    [yv1, yv2] =
      vertical_vertices
      |> Enum.filter(fn {_, [vertex1, vertex2]} -> vertex1 in coords or vertex2 in coords end)
      |> Enum.map(fn {_, vertices} ->
        yv = Enum.find_value(vertices, fn {_, yv} -> if yv != y, do: yv end)

        true = is_integer(yv)

        yv
      end)

    (y > yv1 and y < yv2) or (y < yv1 and y > yv2)
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

  def sub(coord1, coord2) do
    {x1, y1} = coord1
    {x2, y2} = coord2

    {x1 - x2, y1 - y2}
  end
end
