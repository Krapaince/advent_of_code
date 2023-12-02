defmodule Day07 do
  def solve1() do
    filetree = parse_input()

    filetree
    |> make_entries_list([:dir], [])
    |> Enum.map(fn {_, path} ->
      get_entry_from_path(filetree, path)
      |> compute_dir_size()
    end)
    |> Enum.filter(fn size -> size <= 100_000 end)
    |> Enum.sum()
  end

  def solve2() do
    filetree = parse_input()
    root_used_space = compute_dir_size(filetree)
    min_size = 30_000_000 - (70_000_000 - root_used_space)

    filetree
    |> make_entries_list([:dir], [])
    |> Enum.map(fn {_, path} ->
      get_entry_from_path(filetree, path) |> compute_dir_size()
    end)
    |> IO.inspect()
    |> Enum.filter(fn dir_size -> dir_size >= min_size end)
    |> IO.inspect()
    |> List.foldl(nil, fn dir_size, cur_size ->
      cond do
        cur_size |> is_nil() -> dir_size
        dir_size < cur_size -> dir_size
        true -> cur_size
      end
    end)
  end

  def parse_input() do
    Adventcode.get_input_content(7)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn
      [_, _, dir] ->
        {:command, :cd, dir}

      ["$", "ls"] ->
        {:command, :ls}

      ["dir", dir] ->
        {:output, :dir, dir}

      [size, file] ->
        size = size |> String.to_integer()
        {:output, :file, {file, size}}
    end)
    |> make_filetree()
  end

  def make_filetree(commands) do
    commands
    |> List.foldl({%{}, []}, fn command, {filetree, cwd} ->
      case command do
        {:command, :cd, ".."} ->
          cwd = cwd |> pop_child_from_path()

          {filetree, cwd}

        {:command, :cd, "/"} ->
          {create_dir("/"), cwd}

        {:command, :cd, dir} ->
          entry = create_dir(dir)
          filetree = filetree |> push_entry_in_filetree(cwd, entry)

          cwd = cwd |> push_child_to_path(dir)

          {filetree, cwd}

        {:output, :file, {file, size}} ->
          entry = create_file(file, size)
          filetree = filetree |> push_entry_in_filetree(cwd, entry)

          {filetree, cwd}

        _ ->
          {filetree, cwd}
      end
    end)
    |> elem(0)
  end

  def create_file(name, size), do: %{kind: :file, name: name, size: size}
  def create_dir(name, entries \\ %{}), do: %{name: name, kind: :dir, entries: entries}

  def push_entry_in_filetree(filetree, paths, entry) do
    paths = paths |> List.insert_at(-1, entry.name) |> Enum.intersperse(:entries)
    paths = [:entries | paths]

    filetree |> put_in(paths, entry)
  end

  def push_child_to_path(path, child), do: path |> List.insert_at(-1, child)
  def pop_child_from_path(path), do: path |> Enum.drop(-1)

  def make_entries_list(filetree, kinds, path \\ []) do
    filetree.entries
    |> Map.values()
    |> Enum.reduce([], fn entry, entries_list ->
      path = path |> push_child_to_path(entry[:name])
      entry_kind = entry |> Map.fetch!(:kind)

      entries_list =
        if entry_kind in kinds do
          e = {entry_kind, path}

          [e | entries_list]
        else
          entries_list
        end

      case entry_kind do
        :file -> entries_list
        :dir -> entries_list ++ make_entries_list(entry, kinds, path)
      end
    end)
  end

  def get_entry_from_path(filetree, path) do
    path = path |> Enum.intersperse(:entries)

    filetree[:entries] |> get_in(path)
  end

  def compute_dir_size(dir) do
    dir.entries
    |> Enum.map(fn {_, entry} ->
      case entry[:kind] do
        :file -> entry.size
        :dir -> entry |> compute_dir_size()
      end
    end)
    |> Enum.sum()
  end
end
