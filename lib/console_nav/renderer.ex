defmodule ConsoleNav.Renderer do
  alias ConsoleNav.Matrix
  alias ConsoleNav.GameData
  alias ConsoleNav.Navigator
  use GenServer

  @refresh_interval 100
  @coin_texture "$"
  @player_texture "@"
  @wall_texture "#"

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    draw
  end

  defp draw do
    state = GameData.state
    clear_board
    state.board
    |> Matrix.to_list
    |> Enum.with_index
    |> Enum.each(&draw_line/1)
    print_wallet(state)
    print_controls
    :timer.sleep @refresh_interval
    draw
  end

  defp draw_line(line) do
    {row, x} = line
    IO.write "#{IO.ANSI.clear_line}\r"
    row
    |> Enum.with_index
    |> Enum.map(fn({col, y}) -> draw_cell(col, {x, y}) end)
    |> Enum.join(" ")
    |> IO.puts
  end

  defp draw_cell(char, coords) do
    player_location = Navigator.state
    if coords == player_location do
      "#{IO.ANSI.blue}#{@player_texture}"
    else
      case char do
        3 -> "#{IO.ANSI.yellow}#{@coin_texture}"
        1 -> "#{IO.ANSI.white}#{@wall_texture}"
        _ -> "#{IO.ANSI.black} "
      end
    end
  end

  defp clear_board do
    IO.write [
      IO.ANSI.clear,
      IO.ANSI.home
    ]
  end

  defp print_wallet(state) do
    wallet = state.wallet
    IO.puts [
      "\n\n#{IO.ANSI.clear_line}\r",
      IO.ANSI.red,
      "Wallet: #{wallet}"
    ]
  end

  defp print_controls do
    IO.puts  [
      IO.ANSI.cyan,
      "#{IO.ANSI.clear_line}\r",
      "CONTROLS:\n",
      "#{IO.ANSI.clear_line}\r",
      "Arrow keys to navigate\n",
      "#{IO.ANSI.clear_line}\r",
      "Shift + x = exit\n",
      "#{IO.ANSI.clear_line}\r",
      IO.ANSI.reset
    ]
  end
end
