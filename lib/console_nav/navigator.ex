defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  @left {-1, 0}
  @right {1, 0}
  @up {0, -1}
  @down {0, 1}

  def start(initial_position \\ {0,0}) do
    state = %{moving: false, position: initial_position}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_cast(:left, state),  do: {:noreply, move(state, @left)}
  def handle_cast(:right, state), do: {:noreply, move(state, @right)}
  def handle_cast(:up, state),    do: {:noreply, move(state, @up)}
  def handle_cast(:down, state),  do: {:noreply, move(state, @down)}

  def handle_call(:position, _from, state) do
    {:reply, state.position, state}
  end

  def handle_cast(:stop, %{position: pos}) do
    {:noreply, %{moving: false, position: pos}}
  end

  defp move(state = %{moving: moving}, _dir) when moving, do: state

  defp move(%{position: position}, dir) do
    {row, col} = position
    {x, y} = dir
    destination = {row + y, col + x}
    unless collision?(destination, row, col) do
      %{moving: true, position: destination}
    else
      %{moving: true, position: position}
    end
  end

  defp collision?(destination, old_row, old_col) do
    {new_row, new_col} = destination
    %{board: board, wallet: wallet} = GenServer.call(GameData, :state)
    # set every cell that the player moves into to 0 (blank space)
    board = put_in(board[old_row][old_col], 0)
    cell = board[new_row][new_col]
    state = %{board: board, wallet: (if cell == 3, do: wallet + 1, else: wallet)}
    GenServer.cast(GameData, {:set, state})
    Enum.member?([1, nil], cell)
  end
end
