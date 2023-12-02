defmodule Day08 do
  def solve1() do
    parse_input()
    |> _2dmap_to_trees_lines_list()
    |> Enum.map(&mark_visible_tree_in_trees_line/1)
    |> trees_lines_list_to_map()
    |> compute_visible_tree_in_map()
  end

  def solve2() do
    map =
      parse_input()
      |> add_index_to_map(false)

    height = (map |> Enum.count()) - 1
    width = (map |> List.first() |> Enum.count()) - 1
    map_size = {height, width}

    map =
      map
      |> List.flatten()
      |> Map.new()

    0..height
    |> Enum.map(fn y ->
      0..width
      |> Enum.map(fn x ->
        coords = {y, x}

        [:up, :down, :right, :left]
        |> Enum.map(&compute_viewing_dist_fromm_coords_given_direction(map, map_size, coords, &1))
        |> Enum.reject(fn nb -> nb == 0 end)
        |> Enum.reduce(1, fn nb, acc -> acc * nb end)
      end)
      |> Enum.max()
    end)
    |> Enum.max()
  end

  def parse_input() do
    Adventcode.get_input_content(8)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def _2dmap_to_trees_lines_list(map) do
    rotated_map = map |> Enum.zip() |> Enum.map(&Tuple.to_list/1) |> add_index_to_map(true)
    map = map |> add_index_to_map(false)

    left_side = map

    right_side =
      map
      |> Enum.map(fn trees_line -> trees_line |> Enum.reverse() end)

    top_side = rotated_map

    bottom_side =
      rotated_map
      |> Enum.map(fn trees_line -> trees_line |> Enum.reverse() end)

    left_side ++ right_side ++ top_side ++ bottom_side
  end

  def add_index_to_map(map, is_rotated_map) do
    map
    |> Enum.with_index()
    |> Enum.map(fn {trees_line, y} ->
      trees_line
      |> Enum.with_index()
      |> Enum.map(fn {height, x} ->
        case is_rotated_map do
          false -> {{y, x}, height}
          true -> {{x, y}, height}
        end
      end)
    end)
  end

  def mark_visible_tree_in_trees_line(trees) do
    initial_tallest_height = -1

    {trees, _} =
      trees
      |> Enum.map_reduce(initial_tallest_height, fn {coords, height}, tallest_tree ->
        {is_visible, tallest_tree} =
          if height <= tallest_tree do
            {false, tallest_tree}
          else
            {true, height}
          end

        {{coords, height, is_visible}, tallest_tree}
      end)

    trees
  end

  def trees_lines_list_to_map(trees) do
    trees
    |> List.flatten()
    |> Enum.reduce(%{}, fn {coords, height, is_visible}, map ->
      is_visible =
        case map[coords] do
          nil -> is_visible
          {_, tree_is_visible} -> tree_is_visible || is_visible
        end

      map |> put_in([coords], {height, is_visible})
    end)
  end

  def compute_visible_tree_in_map(map) do
    map
    |> Map.values()
    |> Enum.map(fn {_, is_visible} -> (is_visible && 1) || 0 end)
    |> Enum.sum()
  end

  def compute_viewing_dist_fromm_coords_given_direction(
        map,
        {height, width},
        {y, x} = coords,
        direction
      ) do
    max_height = map[coords]

    {alignment, range} =
      case direction do
        :up -> {:vertical, y..0}
        :down -> {:vertical, y..height}
        :left -> {:horizontal, x..0}
        :right -> {:horizontal, x..width}
      end

    previous_tree_height = -1

    range
    |> Stream.drop(1)
    |> Stream.transform(previous_tree_height, fn coord, previous_tree_height ->
      coords =
        case alignment do
          :vertical -> {coord, x}
          :horizontal -> {y, coord}
        end

      tree_height = map[coords]

      {[tree_height <= max_height && previous_tree_height != max_height], tree_height}
    end)
    |> Enum.take_while(fn is_visible -> is_visible end)
    |> Enum.count()
  end
end
