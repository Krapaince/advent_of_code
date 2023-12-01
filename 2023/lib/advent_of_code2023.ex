defmodule AdventOfCode2023 do
  def get_lines(day) do
    get(day)
    |> String.split("\n", trim: true)
  end

  def get(day) do
    fetch!(day)

    File.read!(make_filename(day))
  end

  def fetch!(day) do
    filename = make_filename(day)

    if !File.exists?(filename) do
      cookie = File.read!(".cookie") |> String.replace("\n", "")

      {:ok, {{_, 200, _}, _, content}} =
        :httpc.request(
          :get,
          {'https://adventofcode.com/2023/day/#{day}/input', [{'Cookie', 'session=#{cookie}'}]},
          [],
          []
        )

      filename
      |> Path.dirname()
      |> File.mkdir_p!()

      File.write!(filename, content)

      :ok
    end
  end

  defp make_filename(day), do: "inputs/#{day}"
end
