defmodule ConsoleNav do
  alias ConsoleNav.CLI
  alias ConsoleNav.Navigator

  def main(_args) do
    {:ok, board} = Navigator.start_link
    CLI.start_link(board)
    :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
