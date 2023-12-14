defmodule Day12 do
  def part1() do
    AdventOfCode2023.get_lines("12")
    |> Stream.map(fn line ->
      {springs, chunks_size} = parse_record(line)

      generate_permutations(chunks_size, springs)
      |> Stream.reject(&any_broken_springs_out_of_damaged_chunks?(springs, chunks_size, &1))
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def parse_record(line) do
    [springs, damaged_spring_chunks_size] = String.split(line, " ")

    springs = String.to_charlist(springs)

    damaged_spring_chunks_size =
      damaged_spring_chunks_size |> String.split(",") |> Enum.map(&String.to_integer/1)

    {springs, damaged_spring_chunks_size}
  end

  def generate_permutations(chunks_size, springs, offset \\ 0)
  def generate_permutations([], _, _), do: nil

  def generate_permutations([chunk_size | chunks_size], springs, offset) do
    springs
    |> Stream.drop(offset)
    |> stream_damaged_spring_chunks_offset(chunk_size)
    |> Stream.flat_map(fn chunk_offset ->
      real_chunk_offset = chunk_offset + offset
      next_chunk_offset = real_chunk_offset + chunk_size + 1

      case generate_permutations(chunks_size, springs, next_chunk_offset) do
        nil -> [[real_chunk_offset]]
        sub_chunks_offset -> Enum.map(sub_chunks_offset, &[real_chunk_offset | &1])
      end
    end)
  end

  def stream_damaged_spring_chunks_offset(springs, size) do
    stream_damaged_spring_chunks(springs, size)
    |> Stream.map(fn {offset, _} -> offset end)
  end

  def stream_damaged_spring_chunks(springs, size) do
    springs
    |> Stream.with_index()
    |> Stream.chunk_every(size, 1, :discard)
    |> Stream.map(fn chunk ->
      [{_, offset} | _] = chunk

      springs = Enum.map(chunk, &elem(&1, 0))

      {offset, springs}
    end)
    |> Stream.filter(fn {offset, chunk_springs} ->
      can_damaged_springs_fit?(chunk_springs, size, springs, offset)
    end)
  end

  def can_damaged_springs_fit?(springs_chunk, chunk_size, springs, offset) do
    chunk_damage_or_unknown? =
      Enum.all?(springs_chunk, fn spring -> is_damaged(spring) or is_unknown(spring) end)

    spring_before_chunk =
      if offset == 0,
        do: nil,
        else: Enum.at(springs, offset - 1)

    spring_after_chunk = Enum.at(springs, offset + chunk_size)

    chunk_damage_or_unknown? and is_spring_unknown_or_operational(spring_before_chunk) and
      is_spring_unknown_or_operational(spring_after_chunk)
  end

  def is_spring_unknown_or_operational(nil), do: true

  def is_spring_unknown_or_operational(spring),
    do: is_unknown(spring) or is_operational(spring)

  def is_damaged(spring), do: spring == ?#
  def is_unknown(spring), do: spring == ??
  def is_operational(spring), do: spring == ?.

  def any_broken_springs_out_of_damaged_chunks?(springs, chunks_size, offsets) do
    Stream.zip(chunks_size, offsets)
    |> Stream.flat_map(fn {chunks_size, offset} -> offset..(offset + chunks_size - 1) end)
    |> Enum.reduce(springs, fn index, springs ->
      List.replace_at(springs, index, ?.)
    end)
    |> Enum.any?(&is_damaged/1)
  end

  def apply_string_permutation(springs, chunks_size, offsets) do
    Stream.zip(chunks_size, offsets)
    |> Stream.flat_map(fn {chunks_size, offset} -> offset..(offset + chunks_size - 1) end)
    |> Enum.reduce(springs, fn index, springs ->
      List.replace_at(springs, index, ?#)
    end)
    |> List.to_string()
    |> String.replace("?", ".")
  end
end
