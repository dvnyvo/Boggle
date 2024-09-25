defmodule Boggle do
#501119407 danny vo, d23vo
    def boggle(board, words) do
    word_set = MapSet.new(words)
    min_length = Enum.min(Enum.map(words, &String.length/1))
    trie = build_trie(words)

    Enum.reduce(0..tuple_size(board) - 1, %{}, fn row, acc ->
      Enum.reduce(0..tuple_size(elem(board, 0)) - 1, acc, fn col, acc_inner ->
        dfs(board, row, col, "", %{}, trie, word_set, min_length, acc_inner, [])
      end)
    end)
    |> Enum.map(fn {word, coords} -> {word, Enum.reverse(coords)} end)
    |> Enum.into(%{})
  end

  defp dfs(board, row, col, prefix, visited, trie, word_set, min_length, acc, path) do
    if out_of_bounds?(row, col, board) || Map.get(visited, {row, col}) do
      acc
    else
      char = elem(elem(board, row), col)
      new_prefix = prefix <> char
      new_visited = Map.put(visited, {row, col}, true)
      new_path = [{row, col} | path]
      new_acc =
        if String.length(new_prefix) >= min_length && MapSet.member?(word_set, new_prefix) do
          Map.put(acc, new_prefix, new_path)
        else
          acc
        end

      if Map.has_key?(trie, char) do
        Enum.reduce([-1, 0, 1], new_acc, fn dx, acc1 ->
          Enum.reduce([-1, 0, 1], acc1, fn dy, acc2 ->
            unless dx == 0 && dy == 0 do
              dfs(board, row + dx, col + dy, new_prefix, new_visited, Map.get(trie, char), word_set, min_length, acc2, new_path)
            else
              acc2
            end
          end)
        end)
      else
        new_acc
      end
    end
  end

  defp build_trie(words) do
    Enum.reduce(words, %{}, fn word, trie ->
      trie_insert(String.codepoints(word), trie, word)
    end)
  end

  defp trie_insert([], trie, word) do
    Map.put(trie, :word, word)
  end

  defp trie_insert([char | rest], trie, word) do
    old_subtrie = Map.get(trie, char, %{})
    new_subtrie = trie_insert(rest, old_subtrie, word)
    Map.put(trie, char, new_subtrie)
  end

  defp out_of_bounds?(row, col, board) do
    row < 0 || col < 0 || row >= tuple_size(board) || col >= tuple_size(elem(board, 0))
  end
end
