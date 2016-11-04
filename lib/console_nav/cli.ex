defmodule ConsoleNav.CLI do
  use GenServer
  alias ConsoleNav.Navigator

  def start_link(game) do
    GenServer.start_link(ConsoleNav.CLI, game)
  end

  def init(game) do
    port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
    state = %{
      port: port,
      game: game
    }
    IO.puts "\e[?25l" # hide cursor
    {:ok, state}
  end

  def handle_info({_pid, {:data, data}}, state) do
    translate(data)
    |> handle_key(state)
    {:noreply, state}
  end

  defp translate("\e[A"), do: :move_up
  defp translate("\e[B"), do: :move_down
  defp translate("\e[C"), do: :move_right
  defp translate("\e[D"), do: :move_left
  defp translate("X"), do: :X
  defp translate(_),      do: nil

  defp handle_key(nil, _state), do: :ok
  defp handle_key(key, state) do
    game = state.game
    case key do
      :move_up ->
        Navigator.move(game, :up)
      :move_down ->
        Navigator.move(game, :down)
      :move_right ->
        Navigator.move(game, :right)
      :move_left ->
        Navigator.move(game, :left)
      :X ->
        IO.write "\e[?25h" # show cursor
        IO.write IO.ANSI.reset
        :init.stop
    end
  end
end
