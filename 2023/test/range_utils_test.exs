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

    test "stream_split with a strictly containning splitting range" do
      range = 0..10
      splitting_ranges = [4..6]

      splitted_ranges = RangeUtils.stream_split(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [{:no_match, 0..3}, 4..6, {:no_match, 7..10}]
    end

    test "stream_split with a containning splitting range" do
      range = 0..10
      splitting_ranges = [-1..15]

      splitted_ranges = RangeUtils.stream_split(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [0..10]
    end

    test "stream_split with a disjoinning left splitting range" do
      range = 0..10
      splitting_ranges = [6..10]

      splitted_ranges = RangeUtils.stream_split(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [{:no_match, 0..5}, 6..10]
    end

    test "stream_split with a disjoinning right splitting range" do
      range = 0..10
      splitting_ranges = [0..4]

      splitted_ranges = RangeUtils.stream_split(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [0..4, {:no_match, 5..10}]
    end

    test "stream_split with a multipe splitting ranges" do
      range = 0..100
      splitting_ranges = [1..5, 6..7, 30..40, 70..100]

      splitted_ranges = RangeUtils.stream_split(range, splitting_ranges) |> Enum.to_list()

      assert splitted_ranges == [
               {:no_match, 0..0},
               1..5,
               6..7,
               {:no_match, 8..29},
               30..40,
               {:no_match, 41..69},
               70..100
             ]
    end
  end
end
