# http://blog.danielberkompas.com/2016/04/23/multidimensional-arrays-in-elixir.html
defmodule ConsoleNav.Matrix do
  @moduledoc """
  Helpers for working with multidimensional lists, also called matrices.
  """

  @doc """
  Converts a multidimensional list into a zero-indexed board.

  ## Example

  iex> list = [["x", "o", "x"]]
  ...> Matrix.from_list(list)
  %{0 => %{0 => "x", 1 => "o", 2 => "x"}}
  """
  def from_list(list) when is_list(list) do
    do_from_list(list)
  end

  defp do_from_list(list, board \\ %{}, index \\ 0)
  defp do_from_list([], board, _index), do: board
  defp do_from_list([h|t], board, index) do
    board = Map.put(board, index, do_from_list(h))
    do_from_list(t, board, index + 1)
  end
  defp do_from_list(other, _, _), do: other

  @doc """
  Converts a zero-indexed board into a multidimensional list.

  ## Example

  iex> matrix = %{0 => %{0 => "x", 1 => "o", 2 => "x"}}
  ...> Matrix.to_list(matrix)
  [["x", "o", "x"]]
  """
  def to_list(matrix) when is_map(matrix) do
    do_to_list(matrix)
  end

  defp do_to_list(matrix) when is_map(matrix) do
    for {_index, value} <- matrix,
    into: [],
    do: do_to_list(value)
  end
  defp do_to_list(other), do: other
end

