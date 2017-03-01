defmodule ConsoleNav do
  use Application
  alias ConsoleNav.Navigator
  alias ConsoleNav.Renderer
  alias ConsoleNav.GameData

  def start(_type, _args) do
    GameData.start_link
    Navigator.start_link
    spawn(fn() -> Renderer.start end)
    ConsoleNav.Supervisor.start_link
  end
end
