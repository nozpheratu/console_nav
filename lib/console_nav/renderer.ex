defmodule ConsoleNav.Renderer do
  alias ConsoleNav.Matrix
  alias ConsoleNav.GameData
  alias ConsoleNav.Navigator

  @refresh_interval 100
  @coin "$ "
  @player "\x{2588}\x{2588}"
  @wall "\x{2588}\x{2588}"

  def start, do: loop

  defp loop do
    state = GameData.state
    IO.write [
      clear_screen,
      draw_board(state.board),
      draw_wallet(state.wallet),
      draw_controls
    ]
    :timer.sleep @refresh_interval
    loop
  end

  defp draw_board(board) do
    Matrix.to_list(board)
    |> Enum.with_index
    |> Enum.map(fn(line) -> ["\r", draw_line(line), "\n"] end)
  end

  defp draw_line(line) do
    {row, x} = line
    Enum.with_index(row)
    |> Enum.map(fn({col, y}) -> draw_cell(col, {x, y}) end)
  end

  defp draw_cell(char, pos) do
    if pos == Navigator.state do
      [IO.ANSI.blue, @player, IO.ANSI.reset]
    else
      case char do
        3 -> [IO.ANSI.bright, IO.ANSI.yellow, @coin, IO.ANSI.reset]
        1 -> [IO.ANSI.white, @wall]
        _ -> [IO.ANSI.black, "  "]
      end
    end
  end

  defp clear_screen, do: [IO.ANSI.clear, IO.ANSI.home]

  defp draw_wallet(wallet) do
    [
      IO.ANSI.reset,
      "\n\rWallet: ",
      IO.ANSI.bright,
      IO.ANSI.yellow,
      "#{wallet}",
      IO.ANSI.reset
    ]
  end

  defp draw_controls do
    [
      "\n\rControls: Arrow keys",
      "\n\rShift + x = exit\n",
      "#{IO.ANSI.clear_line}\r",
      IO.ANSI.reset
    ]
  end
end
