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
  Uses `ranges` to split `range` into multiple sub-range. Non matching
  sub-range will be put into a tuple.

  Ranges of `ranges` must not overlap and be sorted by range start.

  ## Examples
    iex> RangeUtils.stream_split(0..15, [2..4, 6..8, 10..14]) |> Enum.to_list()
    [
      {:no_match, 0..1},
      2..4,
      {:no_match, 5..5},
      6..8,
      {:no_match, 9..9},
      10..14,
      {:no_match, 15..15}
    ]
  """
  def stream_split(range, ranges) do
    ranges
    |> Stream.transform(
      fn -> range end,
      fn
        _, nil ->
          {:halt, nil}

        splitter_range, range ->
          is..ie//_ = range
          ss..se//_ = splitter_range

          cond do
            RangeUtils.contains(range, splitter_range) ->
              {[range], nil}

            RangeUtils.disjoint_left?(range, splitter_range) ->
              {
                [{:no_match, is..(ss - 1)}, ss..ie],
                nil
              }

            RangeUtils.disjoint_right?(range, splitter_range) ->
              {
                [is..se],
                (se + 1)..ie
              }

            RangeUtils.strictly_contains?(range, splitter_range) ->
              {
                [{:no_match, is..(ss - 1)}, ss..se],
                (se + 1)..ie
              }
          end
      end,
      fn
        nil -> {:halt, nil}
        range -> {[{:no_match, range}], nil}
      end,
      fn _ -> nil end
    )
  end

  def to_string(range) do
    s..e//_ = range

    "#{s}..#{e}"
  end
end
