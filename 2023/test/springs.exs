defmodule SpringsTest do
  use ExUnit.Case

  describe "Day12.stream_damaged_spring_chunks/2" do
    [
      {[~c"#", 1], [0]},
      {[~c".#.", 1], [1]},
      {[~c".?.", 1], [1]},
      {[~c".?#?.#.#?", 2], [1, 2, 7]},
      {[~c"#??#?#.#?.?", 2], [0, 2, 7]}
    ]
    |> Enum.with_index(fn {params, expected_result}, index ->
      [springs, chunk_size] = params

      msg =
        "Test #{index}: expected to find #{inspect(expected_result, pretty: true)} in #{springs} with chunk size of #{chunk_size}"

      test msg do
        result =
          Day12.stream_damaged_spring_chunks_offset(unquote(springs), unquote(chunk_size))
          |> Enum.to_list()

        assert result == unquote(expected_result)
      end
    end)
  end
end
