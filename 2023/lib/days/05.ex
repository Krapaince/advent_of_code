defmodule Day05 do
  def part1() do
    {seeds, maps} =
      AdventOfCode2023.get("5")
      |> parse_almanac()

    seeds
    |> Stream.map(fn seed ->
      map_seed_to_destination(seed, "location", maps)
    end)
    |> Enum.min()
  end

  def parse_almanac(content) do
    [seeds | maps] = String.split(content, "\n\n")

    seeds = parse_seeds(seeds)
    maps = parse_maps(maps)

    {seeds, maps}
  end

  def parse_seeds(seeds) do
    "seeds: " <> seeds = seeds

    seeds
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_maps(maps), do: Enum.map(maps, &parse_map/1)

  def parse_map(map) do
    [title | ranges] = String.split(map, "\n", trim: true)

    {source, destination} = parse_map_title(title)
    ranges = parse_ranges(ranges)

    %{
      source: source,
      destination: destination,
      ranges: ranges
    }
  end

  def parse_map_title(title) do
    [source, destination] =
      title
      |> String.replace_trailing(" map:", "")
      |> String.split("-to-")

    {source, destination}
  end

  def parse_ranges(ranges), do: Enum.map(ranges, &parse_range/1)

  def parse_range(range) do
    [dest, src, range_len] =
      range |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

    %{
      dest: {dest, dest + range_len - 1},
      src: {src, src + range_len - 1}
    }
  end

  def map_seed_to_destination(seed, destination, maps),
    do: map_source_to_destination(seed, "seed", destination, maps)

  def map_source_to_destination(id, location, location, _), do: id

  def map_source_to_destination(id, source, destination, maps) do
    map = Enum.find(maps, fn %{source: src} -> src == source end)

    id = map_id(id, map)

    map_source_to_destination(id, map.destination, destination, maps)
  end

  def map_id(id, map) do
    map.ranges |> Enum.find_value(id, &map_id_through_range(id, &1))
  end

  def map_id_through_range(id, range) do
    if in_range?(id, range.src) do
      {src, _} = range.src
      {dest, _} = range.dest

      id + (dest - src)
    end
  end

  def in_range?(x, {min, max}), do: x >= min and x <= max
end
