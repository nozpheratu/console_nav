defmodule ConsoleNav.Board do
  use GenServer
  alias ConsoleNav.Matrix

  @player_texture "@"
  @wall_texture "#"

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(board) do
    board = [
      [1, 1, 1, 1, 1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1, 1, 1, 1],
      [1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ]
    |> Matrix.from_list
    draw_board(board)
    {:ok, board}
  end

  def move(pid, :left), do: GenServer.cast(pid, :move_left)
  def move(pid, :right), do: GenServer.cast(pid, :move_right)
  def move(pid, :up), do: GenServer.cast(pid, :move_up)
  def move(pid, :down), do: GenServer.cast(pid, :move_down)
  def draw(pid), do: GenServer.call(pid, :draw)

  defp player_in_row(row) do
    Map.values(row) |> Enum.member?(2)
  end

  defp player_location(board) do
    len = Enum.count(board) - 1
    Enum.map(0..len, fn(i) ->
      if player_in_row(board[i]) do
        row = i
        col = Enum.find_index(board[row], fn {key, val} -> val == 2 end)
        {row , col}
      end
    end)
    |> Enum.max
  end

  defp move_player(old_pos, new_pos, board) do
    {old_row, old_col} = old_pos
    {new_row, new_col} = new_pos
    unless board[new_row][new_col] == 1 do
      board = put_in board[old_row][old_col], 0
      board = put_in board[new_row][new_col], 2
    end
    board
  end

  def handle_cast(:move_left, board) do
    {row, col} = player_location(board)
    {:noreply,  move_player({row, col}, {row, col - 1}, board)}
  end

  def handle_cast(:move_right, board) do
    {row, col} = player_location(board)
    {:noreply, move_player({row, col}, {row, col + 1}, board)}
  end

  def handle_cast(:move_up, board) do
    {row, col} = player_location(board)
    {:noreply, move_player({row, col}, {row - 1, col}, board)}
  end

  def handle_cast(:move_down, board) do
    {row, col} = player_location(board)
    {:noreply, move_player({row, col}, {row + 1, col}, board)}
  end

  def handle_call(:draw, _from, board) do
    draw_board(board)
    {:reply, board, board}
  end

  defp clear_board do
    IO.write IO.ANSI.clear
    IO.write IO.ANSI.home
  end

  defp render(char) do
    case char do
      2 -> "#{IO.ANSI.blue}#{@player_texture}"
      1 -> "#{IO.ANSI.white}#{@wall_texture}"
      _ -> "#{IO.ANSI.black} "
    end
  end

  defp draw_board(board) do
    clear_board
    board
    |> Matrix.to_list
    |> Enum.each(fn(row) ->
      IO.write "#{IO.ANSI.clear_line}\r"
      row
      |> Enum.map(fn(col) -> render(col) end)
      |> Enum.join(" ")
      |> IO.puts
    end)
  end
end
