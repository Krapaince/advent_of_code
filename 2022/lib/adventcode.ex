defmodule Adventcode do
  def get_input_content(day) do
    input_filename = "inputs/day" <> (day |> Integer.to_string() |> String.pad_leading(2, "0"))

    if File.exists?(input_filename) == false do
      session_cookie = File.read!(".cookie")
      "Downloading input of day #{day}" |> IO.puts()

      {:ok, {{_, 200, _}, _, content}} =
        :httpc.request(
          :get,
          {~c"https://adventofcode.com/2022/day/#{day}/input",
           [
             {~c"Cookie", ~c"session=#{session_cookie}"}
           ]},
          [],
          []
        )

      File.write!(input_filename, content)
    end

    File.read!(input_filename)
  end
end
