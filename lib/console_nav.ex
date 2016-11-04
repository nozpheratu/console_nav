defmodule ConsoleNav do
  alias ConsoleNav.CLI
  alias ConsoleNav.Navigator

  def main(_args) do
    {:ok, state} = Navigator.start_link
    CLI.start_link(state)
    :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
