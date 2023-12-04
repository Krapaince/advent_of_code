defmodule Day03 do
  alias Day03.Schematic

  def part1() do
    AdventOfCode2023.get_lines("3")
    |> Schematic.from()
    |> stream_parts()
    |> Stream.map(&Map.fetch!(&1, :nb))
    |> Enum.sum()
  end

  def stream_parts(schematic) do
    schematic.content
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> find_line_maybe_parts()
      |> Enum.map(fn {x, part_nb, len} ->
        %{x: x, y: y, nb: part_nb, len: len}
      end)
    end)
    |> Stream.filter(&is_part(&1, schematic))
  end

  def find_line_maybe_parts(line) do
    line = String.replace(line, ~r/[^0-9]/, " ")

    parts_position =
      line
      |> String.to_charlist()
      |> Stream.with_index(0)
      |> Stream.transform(false, fn {char, x}, was_last_char_a_digit ->
        is_digit = char != ?\s

        position = if is_digit and not was_last_char_a_digit, do: x
        position = List.wrap(position)

        {position, is_digit}
      end)

    raw_parts_nb = String.split(line, " ", trim: true)
    parts_nb = Stream.map(raw_parts_nb, &String.to_integer/1)
    parts_len = Stream.map(raw_parts_nb, &String.length/1)

    Stream.zip([parts_position, parts_nb, parts_len])
  end

  def part2() do
    schematic = AdventOfCode2023.get_lines("3") |> Schematic.from()

    parts =
      schematic
      |> stream_parts()
      |> Enum.to_list()

    schematic
    |> stream_maybe_gear()
    |> Stream.map(fn gear_coord ->
      adjacent_parts =
        stream_adjacent_parts(gear_coord, parts, schematic.dim)
        |> Enum.to_list()

      {gear_coord, adjacent_parts}
    end)
    |> Stream.filter(fn {coord, adjacent_parts} ->
      nb_adjacent_parts = length(adjacent_parts)
      should_keep = nb_adjacent_parts == 2

      if !should_keep do
        IO.inspect("Gear #{inspect(coord)} have #{nb_adjacent_parts} adjacent part.")
      end

      should_keep
    end)
    |> Stream.map(fn {_, [part1, part2]} ->
      part1.nb * part2.nb
    end)
    |> Enum.sum()
  end

  def stream_maybe_gear(schematic) do
    schematic.content
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> find_line_maybe_gear()
      |> Enum.map(fn x -> {x, y} end)
    end)
  end

  def is_part(part, schematic) do
    stream_adjacent_symbol(schematic, part.x, part.y, part.len)
    |> Enum.any?(&is_symbol/1)
  end

  def find_line_maybe_gear(line) do
    Stream.unfold(line, &String.next_grapheme/1)
    |> Stream.with_index()
    |> Stream.filter(fn {graphme, _} -> graphme == "*" end)
    |> Stream.map(&elem(&1, 1))
  end

  def stream_adjacent_parts({x, y}, parts, schema_dim) do
    adjacent_coords = stream_adjacent_coordinates(schema_dim, x, y, 1) |> MapSet.new()

    parts
    |> Stream.filter(fn part ->
      part_adjacent_coords =
        stream_part_coordinates(part.x, part.y, part.len) |> MapSet.new()

      nb_common_adjacent_coords =
        MapSet.intersection(adjacent_coords, part_adjacent_coords)
        |> MapSet.size()

      nb_common_adjacent_coords > 0
    end)
  end

  def stream_adjacent_symbol(schematic, x, y, len) do
    stream_adjacent_coordinates(schematic.dim, x, y, len)
    |> Stream.map(&get_char_at(schematic, &1))
  end

  def stream_adjacent_coordinates(schema_dim, x, y, len) do
    x_min = x - 1
    x_max = x + len
    y_min = y - 1
    y_max = y + 1

    [
      [x_min..x_max, Stream.repeatedly(fn -> y_min end)],
      [x_min..x_max, Stream.repeatedly(fn -> y_max end)],
      [Stream.repeatedly(fn -> x_min end), y_min..y_max],
      [Stream.repeatedly(fn -> x_max end), y_min..y_max]
    ]
    |> Stream.flat_map(&Enum.zip/1)
    |> Stream.filter(fn {x, y} ->
      in_range?(x, 0, schema_dim.x) and in_range?(y, 0, schema_dim.y)
    end)
    |> Stream.uniq()
  end

  def stream_part_coordinates(x, y, len) do
    [x..(x + len - 1), Stream.repeatedly(fn -> y end)]
    |> Stream.zip()
  end

  def get_char_at(schematic, {x, y}) do
    schematic.content |> Enum.at(y) |> String.at(x) |> String.to_charlist() |> hd()
  end

  def is_symbol(char), do: char != ?\. and not in_range?(char, ?0, ?9)

  defp in_range?(nb, min, max), do: nb >= min and nb <= max
end

defmodule Day03.Schematic do
  defstruct [:content, :dim]

  def from(content) do
    %Day03.Schematic{
      content: content,
      dim: %{
        x: (List.first(content) |> String.length()) - 1,
        y: length(content) - 1
      }
    }
  end
end
