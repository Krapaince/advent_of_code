defmodule Day02 do
  @rock 1
  @paper 2
  @scissors 3

  @lost 0
  @draw 3
  @win 6

  def solve1() do
    points = %{
      "A" => %{
        "X" => @rock + @draw,
        "Y" => @paper + @win,
        "Z" => @scissors + @lost
      },
      "B" => %{
        "X" => @rock + @lost,
        "Y" => @paper + @draw,
        "Z" => @scissors + @win
      },
      "C" => %{
        "X" => @rock + @win,
        "Y" => @paper + @lost,
        "Z" => @scissors + @draw
      }
    }

    parse_input()
    |> Enum.map(fn [elf, own] ->
      points[elf][own]
    end)
    |> Enum.sum()
  end

  def solve2() do
    points = %{
      # Rock
      "A" => %{
        "X" => @lost + @scissors,
        "Y" => @draw + @rock,
        "Z" => @win + @paper
      },
      # Paper
      "B" => %{
        "X" => @lost + @rock,
        "Y" => @draw + @paper,
        "Z" => @win + @scissors
      },
      # Scissors
      "C" => %{
        "X" => @lost + @paper,
        "Y" => @draw + @scissors,
        "Z" => @win + @rock
      }
    }

    parse_input()
    |> Enum.map(fn [elf, own] ->
      points[elf][own]
    end)
    |> Enum.sum()
  end

  def parse_input() do
    Adventcode.get_input_content(2)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ")
    end)
  end
end
