defmodule RangeUtils do
  @doc """
  Checks if `r2` is contained in `r1`
  """
  def contains(r1, r2) do
    r1s..r1e//1 = r1
    r2s..r2e//1 = r2

    r1s >= r2s and r1e <= r2e
  end

  @doc """
  Checks if `r2` is strictly contained in `r1` (r1 start and end value are
  exluded from the check.)
  """
  def strictly_contains?(r1, r2) do
    r1s..r1e//1 = r1
    r2s..r2e//1 = r2

    r1s < r2s and r1e > r2e
  end

  @doc """
  Checks if `r2` disjoint but only on left side `r1`
  """
  def disjoint_left?(r1, r2) do
    r1s..r1e//1 = r1
    r2s..r2e//1 = r2

    r1s < r2s and r1e <= r2e
  end

  @doc """
  Checks if `r2` disjoint but only on right side `r1`
  """
  def disjoint_right?(r1, r2) do
    r1s..r1e//1 = r1
    r2s..r2e//1 = r2

    r1s >= r2s and r1e > r2e
  end

  @doc """
  Uses `ranges` to split `range` into multiple sub-range.

  Ranges of `ranges` must not overlap and be sorted by range start.

  ## Examples
    iex> RangeUtils.stream_split_and_shift(0..15, [{2..4, 1}, {6..8, 2}, {10..14, -4}]) |> Enum.to_list()
    [
      0..1,
      3..5,
      5..5,
      8..10,
      9..9,
      6..10,
      15..15
    ]
  """
  @spec stream_split_and_shift(Range.t(), [{Range.t(), integer()}]) :: Enumerable.t([Range.t()])
  def stream_split_and_shift(range, ranges) do
    ranges
    |> Stream.transform(
      fn -> range end,
      fn
        _, nil ->
          {:halt, nil}

        {splitter_range, steps_to_shift}, range ->
          is..ie//_ = range
          ss..se//_ = splitter_range

          cond do
            RangeUtils.contains(range, splitter_range) ->
              {[Range.shift(range, steps_to_shift)], nil}

            RangeUtils.disjoint_left?(range, splitter_range) ->
              {
                [is..(ss - 1), Range.shift(ss..ie, steps_to_shift)],
                nil
              }

            RangeUtils.disjoint_right?(range, splitter_range) ->
              {
                [Range.shift(is..se, steps_to_shift)],
                (se + 1)..ie
              }

            RangeUtils.strictly_contains?(range, splitter_range) ->
              {
                [is..(ss - 1), Range.shift(ss..se, steps_to_shift)],
                (se + 1)..ie
              }
          end
      end,
      fn
        nil -> {:halt, nil}
        range -> {[range], nil}
      end,
      fn _ -> nil end
    )
  end

  def to_string(range) do
    s..e//_ = range

    "#{s}..#{e}"
  end
end
