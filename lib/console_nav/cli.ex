defmodule ConsoleNav.CLI do
  alias ConsoleNav.Navigator

  def main(_args) do
    spawn(&init/0)
    :timer.sleep(:infinity)
  end

  def init do
    {:ok, Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])}
    IO.puts "\e[?25l" # hide cursor
    loop
  end

  def loop do
    receive do
      {_port, {:data, data}} ->
        translate(data)
        |> handle_key
        loop
      _ ->
        loop
    end
  end

  defp translate("\e[A"), do: :up
  defp translate("\e[B"), do: :down
  defp translate("\e[C"), do: :right
  defp translate("\e[D"), do: :left
  defp translate("X"),    do: :exit
  defp translate(_),      do: nil

  defp handle_key(nil), do: :ok
  defp handle_key(key) do
    case key do
      :up ->
        Navigator.move(:up)
      :down ->
        Navigator.move(:down)
      :right ->
        Navigator.move(:right)
      :left ->
        Navigator.move(:left)
      :exit ->
        IO.write "\e[?25h" # show cursor
        IO.write IO.ANSI.reset
        :init.stop
    end
  end
end
