defmodule Day06 do
  @marker_length 14

  def solve1() do
    Adventcode.get_input_content(6)
    |> to_charlist()
    |> Enum.with_index(1)
    |> Enum.reduce_while([], fn {c, i}, previous_chars ->
      is_c_in_previous_char = c in previous_chars

      if !is_c_in_previous_char and previous_chars |> Enum.count() == @marker_length - 1 do
        {:halt, i}
      else
        previous_chars =
          if is_c_in_previous_char do
            previous_chars |> Enum.drop_while(fn char -> char != c end) |> Enum.drop(1)
          else
            previous_chars
          end

        {:cont, previous_chars |> List.insert_at(-1, c)}
      end
    end)
  end
end
