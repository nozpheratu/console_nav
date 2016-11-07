defmodule ConsoleNav do
  alias ConsoleNav.CLI
  alias ConsoleNav.Navigator
  alias ConsoleNav.Renderer
  alias ConsoleNav.GameData

  def main(_args) do
    GameData.start_link
    Navigator.start_link
    CLI.start_link
    Renderer.start_link

    :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
