defmodule Day05Test do
  use ExUnit.Case

  describe "RangeUtils" do
    doctest RangeUtils

    test "r1 contains r2" do
      assert RangeUtils.contains(2..4, 2..4) == true
    end

    test "r1 doesn't contain r2 (upper bound)" do
      assert RangeUtils.contains(1..3, 2..4) == false
    end

    test "r1 doesn't contain r2 (lower bound)" do
      assert RangeUtils.contains(2..5, 2..4) == false
    end

    test "r1 doesn't contain r2" do
      assert RangeUtils.contains(0..1, 2..4) == false
    end

    test "r1 disjoints left from r2" do
      assert RangeUtils.disjoint_left?(0..2, 1..3) == true
    end

    test "r1 doesn't disjoint left from r2 (upper bound)" do
      assert RangeUtils.disjoint_left?(0..3, 0..2) == false
    end

    test "r1 doesn't disjoint left from r2 (lower bound)" do
      assert RangeUtils.disjoint_left?(1..2, 0..1) == false
    end

    test "r1 disjoints right from r2" do
      assert RangeUtils.disjoint_right?(2..4, 0..3) == true
    end

    test "r1 doesn't disjoint right from r2 (lower bound)" do
      assert RangeUtils.disjoint_right?(2..4, 0..5) == false
    end

    test "r1 doesn't disjoint right from r2 (upper bound)" do
      assert RangeUtils.disjoint_right?(2..4, 3..3) == false
    end

    test "r1 strictly contains r2" do
      assert RangeUtils.strictly_contains?(1..5, 2..3) == true
    end

    test "r1 doesn't strictly contain r2 (upper bound)" do
      assert RangeUtils.strictly_contains?(1..5, 2..5) == false
    end

    test "r1 doesn't strictly contain r2 (lower bound)" do
      assert RangeUtils.strictly_contains?(1..5, 1..3) == false
    end

    test "stream_split_and_shift with a strictly containning splitting range" do
      range = 0..10
      splitting_ranges = [{4..6, 1}]

      splitted_ranges =
        RangeUtils.stream_split_and_shift(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [0..3, 5..7, 7..10]
    end

    test "stream_split_and_shift with a containning splitting range" do
      range = 0..10
      splitting_ranges = [{-1..15, 4}]

      splitted_ranges =
        RangeUtils.stream_split_and_shift(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [4..14]
    end

    test "stream_split_and_shift with a disjoinning left splitting range" do
      range = 0..10
      splitting_ranges = [{6..10, -4}]

      splitted_ranges =
        RangeUtils.stream_split_and_shift(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [0..5, 2..6]
    end

    test "stream_split_and_shift with a disjoinning right splitting range" do
      range = 0..10
      splitting_ranges = [{0..4, 10}]

      splitted_ranges =
        RangeUtils.stream_split_and_shift(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [10..14, 5..10]
    end

    test "stream_split_and_shift with a multipe splitting ranges" do
      range = 0..100
      splitting_ranges = [{1..5, 0}, {6..7, 2}, {30..40, -10}, {70..100, -30}]

      splitted_ranges =
        RangeUtils.stream_split_and_shift(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [
               0..0,
               1..5,
               8..9,
               8..29,
               20..30,
               41..69,
               40..70
             ]
    end
  end
end
