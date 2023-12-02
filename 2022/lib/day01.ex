defmodule Day01 do
  def solve() do
    Day01.parse_input() |> Enum.sort(:desc) |> Enum.take(3) |> Enum.sum()
  end

  def solve1() do
    Day01.parse_input()
    |> Enum.sort(:desc)
    |> List.first()
  end

  def parse_input() do
    Adventcode.get_input_content(1)
    |> String.split("\n")
    |> Enum.chunk_by(fn value -> value == "" end)
    |> Enum.reject(fn value -> value == [""] end)
    |> Enum.map(fn calories ->
      calories
      |> Enum.map(fn calorie -> calorie |> String.to_integer() end)
      |> Enum.sum()
    end)
  end
end
