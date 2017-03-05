defmodule CoinGeneratorTest do
  use ExUnit.Case
  alias ConsoleNav.CoinGenerator

  defp board do
    [
      [0,0,0,0,0,0,0,0],
      [0,0,0,0,1,1,1,0],
      [0,0,0,0,0,0,1,0],
      [0,0,0,0,0,0,1,0],
      [0,0,1,1,1,0,1,0],
      [0,0,0,0,1,0,1,0],
      [0,0,0,0,1,0,0,0],
      [0,0,0,0,1,0,0,0],
      [0,0,0,0,1,0,0,0],
      [0,0,0,0,0,0,0,0]
    ]
  end

  test "it inserts coins to the board" do
    assert board != CoinGenerator.insert(board, 0)
  end

  test "it returns the original board when it can't fulfill the requirements" do
    impossible_board = [[]]
    assert impossible_board == CoinGenerator.insert(impossible_board, CoinGenerator.sanity_max - 1)
  end
end
