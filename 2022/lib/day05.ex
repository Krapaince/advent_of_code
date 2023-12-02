defmodule Day05 do
  def solve1() do
    {stacks, commands} = parse_input()

    stacks =
      commands
      |> Enum.reduce(stacks, fn command, stacks ->
        [nb_crates, stack_start, stack_end] = command

        0..(nb_crates - 1)
        |> Enum.reduce(stacks, fn _, stacks ->
          [box | new_stack_start] = stacks[stack_start]

          stacks
          |> put_in([stack_start], new_stack_start)
          |> put_in([stack_end], [box | stacks[stack_end]])
        end)
      end)

    stacks |> get_top_crates()
  end

  def solve2() do
    {stacks, commands} = parse_input()

    stacks =
      commands
      |> Enum.reduce(stacks, fn command, stacks ->
        [nb_crates, stack_start, stack_end] = command

        case nb_crates do
          0 ->
            stacks

          1 ->
            [box | new_stack_start] = stacks[stack_start]

            stacks
            |> put_in([stack_start], new_stack_start)
            |> put_in([stack_end], [box | stacks[stack_end]])

          nb_crate ->
            {moved_crates, new_stack_start} = stacks[stack_start] |> Enum.split(nb_crate)

            stacks
            |> put_in([stack_start], new_stack_start)
            |> put_in([stack_end], moved_crates ++ stacks[stack_end])
        end
      end)

    stacks |> get_top_crates()
  end

  def parse_input() do
    {stacks, commands} =
      Adventcode.get_input_content(5)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Enum.split_while(fn value -> value != "" end)

    commands = commands |> Enum.drop(1)

    stacks = stacks |> parse_stacks()
    commands = commands |> parse_commands()

    {stacks, commands}
  end

  def parse_stacks(stacks) do
    stacks_ids =
      stacks
      |> Enum.at(-1)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    stacks =
      stacks
      |> Enum.drop(-1)
      |> Enum.map(fn stack_line ->
        stack_line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, index} ->
          if rem(index + 1, 4) == 0 do
            "."
          else
            c
          end
        end)
        |> Enum.into("")
        |> String.split(".")
        |> Enum.map(fn
          "   " -> nil
          crate -> crate |> String.at(1)
        end)
      end)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(fn stack -> stack |> Enum.reject(&is_nil/1) end)

    Enum.zip(stacks_ids, stacks) |> Enum.into(%{})
  end

  def parse_commands(commands) do
    commands
    |> Enum.map(fn command ->
      [_, nb_crates, _, stack_start, _, stack_end] = command |> String.split(" ")

      [nb_crates, stack_start, stack_end] |> Enum.map(&String.to_integer/1) |> Enum.into([])
    end)
  end

  def get_top_crates(stacks) do
    stacks |> Enum.map(fn {_, [top_crate | _]} -> top_crate end) |> Enum.into("")
  end
end
