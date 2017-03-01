defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  @left {-1, 0}
  @right {1, 0}
  @up {0, -1}
  @down {0, 1}

  def start_link do
    inital_state = {1, 1}
    GenServer.start_link(__MODULE__, inital_state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  defp move(old_pos, dir) do
    game_state = GameData.state
    board =  game_state.board
    wallet = game_state.wallet
    {old_row, old_col} = old_pos
    {x, y} = dir
    new_row = old_row + y
    new_col = old_col + x
    move_to = board[new_row][new_col]
    # ensure that anywhere the player moves is assigned as a blank space
    board = put_in board[old_row][old_col], 0
    %{board: board, wallet: (if move_to == 3, do: wallet + 1, else: wallet)}
    |> GameData.set
    # Move or don't move according to the collision check
    unless (Enum.member?([1, nil], move_to)), do: {new_row, new_col}, else: old_pos
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
end
