defmodule Day10 do
  # register start at value 1
  # addx -> takes two cycles
  # noop -> takes one cycles

  def solve1() do
    parse_input()
    |> Map.new()
    |> Map.take([20, 60, 100, 140, 180, 220])
    |> Enum.map(fn {cycle, {_, register}} -> cycle * register end)
    |> Enum.sum()
  end

  def solve2() do
    width = 40
    height = 6

    screen =
      fn -> "." end
      |> Stream.repeatedly()
      |> Enum.take(width)
      |> Kernel.then(fn line -> fn -> line end end)
      |> Stream.repeatedly()
      |> Enum.take(height)

    parse_input()
    |> Enum.to_list()
    |> List.foldl(screen, fn {cycle, {_, register}}, screen ->
      position = cycle |> Kernel.-(1) |> rem(width)

      if position in (register - 1)..(register + 1) do
        line_nb = cycle |> Kernel.-(1) |> Kernel./(width) |> floor()

        line =
          screen
          |> Enum.at(line_nb)
          |> List.replace_at(position, "#")

        screen |> List.replace_at(line_nb, line)
      else
        screen
      end
    end)
    |> Enum.join("\n")
    |> IO.puts()

    # FECZELHE
  end

  def parse_input() do
    Adventcode.get_input_content(10)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn
      ["noop"] -> [:noop]
      ["addx", nb] -> [:addx_start, {:addx_end, nb |> String.to_integer()}]
    end)
    |> List.flatten()
    |> Enum.with_index(1)
    |> Stream.transform(1, fn {instruction, cycle}, register ->
      {instruction, next_register} =
        case instruction do
          {:addx_end, nb} -> {:addx_end, register + nb}
          instruction -> {instruction, register}
        end

      {[{cycle, {instruction, register}}], next_register}
    end)
  end
end
