defmodule Day08 do
  def part1() do
    {instructions, map} =
      AdventOfCode2023.get("8")
      |> parse_map()

    get_node("AAA", map)
    |> stream_steps(instructions, map)
    |> Stream.take_while(fn node -> node != "ZZZ" end)
    |> Enum.to_list()
    |> Enum.count()
    |> Kernel.+(1)
  end

  def part2() do
    {instructions, map} =
      AdventOfCode2023.get("8")
      |> parse_map()

    true = do_nodes_ending_with_a_wrap_after_z?(instructions, map)

    map
    |> Enum.filter(fn {node_id, _} -> String.ends_with?(node_id, "A") end)
    |> Enum.map(fn node ->
      stream_steps(node, instructions, map)
      |> Stream.take_while(fn node -> not String.ends_with?(node, "Z") end)
      |> Enum.count()
      |> Kernel.+(1)
    end)
    |> Day08.Math.lcm()
  end

  def do_nodes_ending_with_a_wrap_after_z?(instructions, map) do
    map
    |> Enum.filter(fn {node_id, _} -> String.ends_with?(node_id, "A") end)
    |> Enum.all?(fn node ->
      before_z =
        stream_steps(node, instructions, map)
        |> Enum.take_while(&String.ends_with?(&1, "Z"))

      after_z =
        stream_steps(node, instructions, map)
        |> Stream.drop_while(&String.ends_with?(&1, "Z"))
        |> Stream.drop(1)
        |> Enum.take_while(&String.ends_with?(&1, "Z"))

      before_z == after_z
    end)
  end

  def parse_map(content) do
    [instructions, map] = String.split(content, "\n\n", trim: true)

    instructions =
      instructions
      |> String.to_charlist()
      |> Stream.map(fn
        ?L -> 0
        ?R -> 1
      end)
      |> Stream.cycle()

    map =
      map
      |> String.split("\n", trim: true)
      |> Map.new(&parse_node/1)

    {instructions, map}
  end

  def parse_node(node) do
    [node, left, right] =
      node
      |> String.replace([" ", "(", ")"], "")
      |> String.split(["=", ","])

    {node, {left, right}}
  end

  def stream_steps(node, instructions, map) do
    instructions
    |> Stream.transform(
      node,
      fn instruction, node ->
        next_node = apply_instructions(node, instruction, map)
        next_node_id = elem(next_node, 0)

        {[next_node_id], next_node}
      end
    )
  end

  def apply_instructions(node, instruction, map) do
    elem(node, 1) |> elem(instruction) |> get_node(map)
  end

  def get_node(node_id, map) do
    connected_node = Map.fetch!(map, node_id)

    {node_id, connected_node}
  end
end

defmodule Day08.Math do
  def lcm([a]), do: a
  def lcm([a | tl]), do: lcm(a, lcm(tl))

  def lcm(a, 0), do: a
  def lcm(a, b), do: div(abs(a * b), gcb(a, b))

  def gcb(a, 0), do: a
  def gcb(a, b) when a < b, do: gcb(b, a)
  def gcb(a, b), do: gcb(rem(a, b), b)
end
