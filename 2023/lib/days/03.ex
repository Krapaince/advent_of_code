defmodule Day03 do
  alias Day03.Schematic

  def part1() do
    schematic = AdventOfCode2023.get_lines("3") |> Schematic.from()

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
    |> Stream.map(&Map.fetch!(&1, :nb))
    |> Enum.sum()
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

  def is_part(part, schematic) do
    stream_adjacent_symbol(schematic, part.x, part.y, part.len)
    |> Enum.any?(&is_symbol/1)
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
