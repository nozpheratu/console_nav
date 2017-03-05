defmodule ConsoleNav.CoinGenerator do
  @moduledoc """
  Procedurally inserts coins into a board.
  """

  @chance 7 # percent chance of adding a coin per cell
  @sanity_max 250000 # max attempts before giving up
  @min_coins 5
  @max_coins 12

  def insert(board, sanity) when sanity > @sanity_max, do: board
  def insert(board, sanity) do
    attempt = board
    |> Enum.map(fn(row) -> Enum.map(row, &generate/1) end)
    count = count(attempt)
    if(enough?(count), do: attempt, else: insert(board, sanity + 1))
  end

  def sanity_max, do: @sanity_max

  defp count(board) do
    Enum.flat_map(board, &(&1))
    |> List.foldl(0, fn(x, acc) -> if(x == 3, do: acc + 1, else: acc) end)
  end

  defp enough?(count) do
    count >= @min_coins && count <= @max_coins
  end

  defp generate(col) when col == 1, do: col
  defp generate(col) do
    if(Enum.random(1..100) < @chance, do: Enum.random([col, 3]), else: col)
  end
end
