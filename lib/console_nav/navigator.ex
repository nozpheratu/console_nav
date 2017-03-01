defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  @left {-1, 0}
  @right {1, 0}
  @up {0, -1}
  @down {0, 1}

  def start_link do
    inital_pos = {1, 1}
    GenServer.start_link(__MODULE__, inital_pos, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(:move_left, state), do: {:noreply, move(state, @left)}
  def handle_cast(:move_right, state), do: {:noreply, move(state, @right)}
  def handle_cast(:move_up, state), do: {:noreply, move(state, @up)}
  def handle_cast(:move_down, state), do: {:noreply, move(state, @down)}

  def state, do: GenServer.call(__MODULE__, :state)

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def move(:left), do: GenServer.cast(__MODULE__, :move_left)
  def move(:right), do: GenServer.cast(__MODULE__, :move_right)
  def move(:up), do: GenServer.cast(__MODULE__, :move_up)
  def move(:down), do: GenServer.cast(__MODULE__, :move_down)

  defp move(origin, dir) do
    {row, col} = origin
    {x, y} = dir
    destination = {row + y, col + x}
    unless collision?(destination, row, col), do: destination, else: origin
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
