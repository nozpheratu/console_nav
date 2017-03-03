defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  @left {-1, 0}
  @right {1, 0}
  @up {0, -1}
  @down {0, 1}

  def start(game \\ GameData, position \\ {0,0}) do
    state = %{moving: false, position: position, game: game}
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

  def handle_cast(:stop, state) do
    {:noreply, Map.merge(state, %{moving: false})}
  end

  defp move(state = %{moving: moving}, _dir) when moving, do: state

  defp move(state = %{position: position, game: game}, dir) do
    {row, col} = position
    {x, y} = dir
    destination = {row + y, col + x}
    unless collision?(game, destination, row, col) do
      Map.merge(state, %{moving: true, position: destination})
    else
      state
    end
  end

  defp collision?(game, destination, old_row, old_col) do
    {new_row, new_col} = destination
    %{board: board, wallet: wallet} = GenServer.call(game, :state)
    # set every cell that the player moves into to 0 (blank space)
    board = put_in(board[old_row][old_col], 0)
    cell = board[new_row][new_col]
    state = %{board: board, wallet: (if cell == 3, do: wallet + 1, else: wallet)}
    GenServer.cast(game, {:set, state})
    Enum.member?([1, nil], cell)
  end
end
