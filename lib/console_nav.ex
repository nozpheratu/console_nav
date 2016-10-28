defmodule ConsoleNav do
  alias ConsoleNav.CLI
  alias ConsoleNav.Board

  def main(_args) do
    {:ok, board} = Board.start_link
    CLI.start_link(board)
    :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
