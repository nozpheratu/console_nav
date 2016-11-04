defmodule ConsoleNav.GameData do
  alias ConsoleNav.Matrix

  ####################
  ##### Legend #######
  ####################
  # 1: wall
  # 2: player
  # 3: empty
  @initial_board [
    [1, 1, 1, 1, 1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1, 1, 1, 1],
    [1, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1],
    [1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 1, 3, 0, 0, 1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 3, 1],
    [1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1],
    [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ]
  @coin_texture "$"
  @player_texture "@"
  @wall_texture "#"

  def initial_state do
    board = Matrix.from_list(@initial_board)
    %{board: board, wallet: 0}
  end

  def draw(state) do
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
