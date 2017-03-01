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
    IO.write [
      IO.ANSI.reset,
      draw_wallet(state),
      draw_controls
    ]
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
      [IO.ANSI.bright, IO.ANSI.blue, @player_texture, IO.ANSI.reset]
    else
      case char do
        3 -> [IO.ANSI.bright, IO.ANSI.yellow, @coin_texture, IO.ANSI.reset]
        1 -> [IO.ANSI.white, @wall_texture]
        _ -> [IO.ANSI.black, " "]
      end
    end
  end

  defp clear_board do
    IO.write [
      IO.ANSI.clear,
      IO.ANSI.home
    ]
  end

  defp draw_wallet(state) do
    wallet = state.wallet
    [
     "\n#{IO.ANSI.clear_line}\r",
      "Wallet: ",
      IO.ANSI.bright,
      IO.ANSI.yellow,
      "#{wallet}",
      IO.ANSI.reset
    ]
  end

  defp draw_controls do
    [
      "\n#{IO.ANSI.clear_line}\r",
      "Controls: Arrow keys\n",
      "#{IO.ANSI.clear_line}\r",
      "Shift + x = exit\n",
      "#{IO.ANSI.clear_line}\r",
      IO.ANSI.reset
    ]
  end
end
