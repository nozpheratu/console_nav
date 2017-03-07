defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  @left {-1, 0}
  @right {1, 0}
  @up {0, -1}
  @down {0, 1}

  def start(game \\ GameData, position \\ {0,0}) do
    state = %{moving: false, position: position, game: game, wallet: 0}
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

  def handle_call(:wallet, _from, state) do
    {:reply, state.wallet, state}
  end

  def handle_cast(:stop, state) do
    {:noreply, Map.merge(state, %{moving: false})}
  end

  defp move(state = %{moving: moving}, _dir) when moving, do: state

  defp move(state = %{position: position, game: game}, dir) do
    {row, col} = position
    {x, y} = dir
    destination = {row + y, col + x}
    {state, collision} = check_collision(state, destination, row, col)
    unless collision do
      Map.merge(state, %{moving: true, position: destination})
    else
      state
    end
  end

  defp check_collision(state, destination, old_row, old_col) do
    %{game: game, wallet: wallet} = state
    {new_row, new_col} = destination
    %{board: board} = GenServer.call(game, :state)
    # set every cell that the player moves into to 0 (blank space)
    board = put_in(board[old_row][old_col], 0)
    cell = board[new_row][new_col]
    GenServer.cast(game, {:set, %{board: board}})
    state = if(cell == 3, do: Map.merge(state, %{wallet: wallet + 1}), else: state)
    {state, Enum.member?([1, nil], cell)}
  end
end
