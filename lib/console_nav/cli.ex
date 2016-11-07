defmodule ConsoleNav.CLI do
  use GenServer
  alias ConsoleNav.Navigator

  def start_link do
    GenServer.start_link(ConsoleNav.CLI, nil)
  end

  def init(_) do
    port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
    IO.puts "\e[?25l" # hide cursor
    {:ok, port}
  end

  def handle_info({_pid, {:data, data}}, port) do
    translate(data)
    |> handle_key
    {:noreply, port}
  end

  defp translate("\e[A"), do: :move_up
  defp translate("\e[B"), do: :move_down
  defp translate("\e[C"), do: :move_right
  defp translate("\e[D"), do: :move_left
  defp translate("X"), do: :exit
  defp translate(_),      do: nil

  defp handle_key(nil), do: :ok
  defp handle_key(key) do
    case key do
      :move_up ->
        Navigator.move(:up)
      :move_down ->
        Navigator.move(:down)
      :move_right ->
        Navigator.move(:right)
      :move_left ->
        Navigator.move(:left)
      :exit ->
        IO.write "\e[?25h" # show cursor
        IO.write IO.ANSI.reset
        :init.stop
    end
  end
end
