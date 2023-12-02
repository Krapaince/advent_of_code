defmodule Day09 do
  def solve() do
    directions =
      Adventcode.get_input_content(9)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [direction, repetition] =
          line
          |> String.split(" ")

        repetition = repetition |> String.to_integer()

        fn -> direction end |> Stream.repeatedly() |> Enum.take(repetition)
      end)
      |> List.flatten()

    rope = fn -> {0, 0} end |> Stream.repeatedly() |> Enum.take(10)

    visited_cells = MapSet.new()

    {_rope, visited_cells} =
      directions
      |> List.foldl({rope, visited_cells}, fn direction, {rope, visited_cells} ->
        rope =
          rope
          |> Stream.transform(nil, fn
            rope_part, ahead_rope_part ->
              rope_part = move_rope_part(rope_part, ahead_rope_part, direction)

              {[rope_part], rope_part}
          end)
          |> Enum.to_list()

        rope_tail = rope |> List.last()
        visited_cells = visited_cells |> MapSet.put(rope_tail)

        {rope, visited_cells}
      end)

    visited_cells |> MapSet.size()
  end

  def move_rope_part(rope_part, ahead_rope_part, direction) do
    {x, y} = rope_part

    case ahead_rope_part do
      nil ->
        current =
          case direction do
            "L" -> {x - 1, y}
            "R" -> {x + 1, y}
            "D" -> {x, y - 1}
            "U" -> {x, y + 1}
          end

        current

      {ax, ay} ->
        dx = (ax - x) |> abs()
        dy = (ay - y) |> abs()

        should_move = max(dx, dy) > 1

        if should_move do
          {dx, dy} = apply_operation_to_positions(ahead_rope_part, rope_part, &Kernel.-/2)

          delta = {
            dx |> clip(),
            dy |> clip()
          }

          apply_operation_to_positions(rope_part, delta, &Kernel.+/2)
        else
          rope_part
        end
    end
  end

  def apply_operation_to_positions({p1x, p1y}, {p2x, p2y}, func) do
    {
      func.(p1x, p2x),
      func.(p1y, p2y)
    }
  end

  def clip(x) when x in -1..1, do: x
  def clip(x), do: (x * 0.5) |> round()
end
