defmodule EnumUtils do
  def async_map_chunked(enumarable, fun, chunks_args, task_opts \\ []) do
    [count, step, leftover] =
      case chunks_args do
        [count] -> [count, count, []]
        [count, nil, leftover] -> [count, count, leftover]
        [_, _, _] -> chunks_args
      end

    enumarable
    |> Stream.chunk_every(count, step, leftover)
    |> Task.async_stream(&Enum.map(&1, fun), task_opts)
    |> Enum.flat_map(fn {:ok, x} -> x end)
  end
end
