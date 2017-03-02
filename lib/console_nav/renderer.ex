defmodule ConsoleNav.Renderer do
  alias ConsoleNav.Matrix
  alias ConsoleNav.GameData
  alias ConsoleNav.Navigator

  @refresh_interval 100
  @coin  [IO.ANSI.bright, IO.ANSI.yellow, "$ ", IO.ANSI.reset]
  @player [IO.ANSI.blue, "\x{2588}\x{2588}", IO.ANSI.reset]
  @wall [IO.ANSI.white, "\x{2588}\x{2588}"]
  @corner [IO.ANSI.white, "\x{2588}\x{2588}\x{2588}\x{2588}"]
  @space [IO.ANSI.black, "  "]

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

  defp is_player?(pos), do: Navigator.position == pos

  defp clear_screen, do: [IO.ANSI.clear, IO.ANSI.home]

  defp draw_board(board) do
    list = Matrix.to_list(board)
    text = list
    |> Enum.with_index
    |> Enum.map(fn(line) -> ["\r", @wall, draw_line(line), @wall, "\n"] end)
    border = Enum.map(Enum.at(list, 1), fn(_) -> @wall end)
    ["#{@corner}#{border}\n", text, "\r#{border}#{@corner}\n"]
  end

  defp draw_line(line) do
    {row, x} = line
    Enum.with_index(row)
    |> Enum.map(fn({col, y}) -> draw_cell(col, {x, y}) end)
  end

  defp draw_cell(char, pos) do
    if is_player?(pos), do: draw_player, else: draw_object(char)
  end

  defp draw_player do
    Navigator.stop
    @player
  end

  defp draw_object(char) when char == 1, do: @wall
  defp draw_object(char) when char == 3, do: @coin
  defp draw_object(_), do: @space

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
