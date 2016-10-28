defmodule ConsoleNav.CLI do
  use GenServer
  alias ConsoleNav.Board

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
    # puts "\e[?25h" # show cursor
    {:ok, state}
  end

  def handle_info({_pid, {:data, data}}, state) do
    translate(data)
    |> handle_key(state)
    ConsoleNav.Board.draw(state.game)
    {:noreply, state}
  end

  defp translate("\e[A"), do: :move_up
  defp translate("\e[B"), do: :move_down
  defp translate("\e[C"), do: :move_right
  defp translate("\e[D"), do: :move_left
  defp translate(_),      do: nil

  defp handle_key(nil), do: :ok
  defp handle_key(key, state) do
    game = state.game
    case key do
      :move_up ->
        Board.move(game, :up)
      :move_down ->
        Board.move(game, :down)
      :move_right ->
        Board.move(game, :right)
      :move_left ->
        Board.move(game, :left)
    end
  end
end
