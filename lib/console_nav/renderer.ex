defmodule ConsoleNav.Renderer do
  alias ConsoleNav.Matrix
  alias ConsoleNav.GameData
  use GenServer

  @coin_texture "$"
  @player_texture "@"
  @wall_texture "#"

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    draw
    Process.send_after(self, :draw, 100)
    {:ok, nil}
  end

  def handle_info(:draw, _) do
    draw
    Process.send_after(self, :draw, 50)
    {:noreply, nil}
  end

  def draw do
    state = GameData.state(GameState)
    clear_board
    state.board
    |> Matrix.to_list
    |> Enum.each(fn(row) ->
      IO.write "#{IO.ANSI.clear_line}\r"
      row
      |> Enum.map(fn(col) -> render(col) end)
      |> Enum.join(" ")
      |> IO.puts
    end)
      print_wallet(state.wallet)
      print_controls
    state
  end

  defp render(char) do
    case char do
      3 -> "#{IO.ANSI.yellow}#{@coin_texture}"
      2 -> "#{IO.ANSI.blue}#{@player_texture}"
      1 -> "#{IO.ANSI.white}#{@wall_texture}"
      _ -> "#{IO.ANSI.black} "
    end
  end

  defp clear_board do
    IO.write IO.ANSI.clear
    IO.write IO.ANSI.home
  end

  defp print_wallet(wallet) do
    IO.write "\n\n"
    IO.write "#{IO.ANSI.clear_line}\r"
    IO.write IO.ANSI.red
    IO.write "Wallet: #{wallet}"
  end

  defp print_controls do
    IO.write "\n\n"
    IO.write IO.ANSI.cyan
    IO.write "#{IO.ANSI.clear_line}\r"
    IO.puts "CONTROLS:"
    IO.write "#{IO.ANSI.clear_line}\r"
    IO.puts "Arrow keys to navigate"
    IO.write "#{IO.ANSI.clear_line}\r"
    IO.write "Shift + x = exit"
  end
end
