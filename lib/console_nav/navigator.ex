defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  def start_link do
    GenServer.start_link(__MODULE__, GameData.initial_state)
  end

  def init(state) do
    GameData.draw(state)
    {:ok, state}
  end

  def move(pid, :left), do: GenServer.cast(pid, :move_left)
  def move(pid, :right), do: GenServer.cast(pid, :move_right)
  def move(pid, :up), do: GenServer.cast(pid, :move_up)
  def move(pid, :down), do: GenServer.cast(pid, :move_down)
  def draw(pid), do: GenServer.call(pid, :draw)

  defp player_in_row(row) do
    Map.values(row) |> Enum.member?(2)
  end

  defp player_location(state) do
    board = state.board
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

  defp move_player(old_pos, new_pos, state) do
    board = state.board
    wallet = state.wallet
    {old_row, old_col} = old_pos
    {new_row, new_col} = new_pos
    move_to = board[new_row][new_col]
    unless Enum.member?([1, nil], move_to) do
      board = put_in board[old_row][old_col], 0
      board = put_in board[new_row][new_col], 2
    end
    %{board: board, wallet: (if move_to == 3, do: wallet + 1, else: wallet)}
    |> GameData.draw
  end

  def handle_cast(:move_left, state) do
    {row, col} = player_location(state)
    {:noreply,  move_player({row, col}, {row, col - 1}, state)}
  end

  def handle_cast(:move_right, state) do
    {row, col} = player_location(state)
    {:noreply, move_player({row, col}, {row, col + 1}, state)}
  end

  def handle_cast(:move_up, state) do
    {row, col} = player_location(state)
    {:noreply, move_player({row, col}, {row - 1, col}, state)}
  end

  def handle_cast(:move_down, state) do
    {row, col} = player_location(state)
    {:noreply, move_player({row, col}, {row + 1, col}, state)}
  end

  def handle_call(:draw, _from, state) do
    GameData.draw(state)
    {:reply, state, state}
  end
end
