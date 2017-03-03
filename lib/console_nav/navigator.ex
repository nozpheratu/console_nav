defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  @left {-1, 0}
  @right {1, 0}
  @up {0, -1}
  @down {0, 1}

  def start_link(initial_position \\ {0,0}) do
    state = %{moving: false, position: initial_position}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def input(:left), do: GenServer.cast(__MODULE__, :left)
  def input(:right), do: GenServer.cast(__MODULE__, :right)
  def input(:up), do: GenServer.cast(__MODULE__, :up)
  def input(:down), do: GenServer.cast(__MODULE__, :down)

  def handle_cast(:left, state), do: {:noreply, move(state, @left)}
  def handle_cast(:right, state), do: {:noreply, move(state, @right)}
  def handle_cast(:up, state), do: {:noreply, move(state, @up)}
  def handle_cast(:down, state), do: {:noreply, move(state, @down)}

  def position, do: GenServer.call(__MODULE__, :position)

  def handle_call(:position, _from, state) do
    {:reply, state.position, state}
  end

  def stop, do: GenServer.cast(__MODULE__, :stop)

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
    game_state = GameData.state
    board =  game_state.board
    wallet = game_state.wallet
    # ensure that anywhere the player moves is assigned as a blank space
    board = put_in board[old_row][old_col], 0
    cell = board[new_row][new_col]
    %{board: board, wallet: (if cell == 3, do: wallet + 1, else: wallet)}
    |> GameData.set
    Enum.member?([1, nil], cell)
  end
end
