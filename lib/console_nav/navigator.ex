defmodule ConsoleNav.Navigator do
  use GenServer
  alias ConsoleNav.GameData

  def start_link do
    inital_state = {1, 1}
    GenServer.start_link(__MODULE__, inital_state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  defp move(old_pos, new_pos, state) do
    game_state = GameData.state
    board =  game_state.board
    wallet = game_state.wallet
    {new_row, new_col} = new_pos
    {old_row, old_col} = old_pos
    move_to = board[new_row][new_col]
    # ensure that anywhere the player moves is assigned as a blank space
    board = put_in board[old_row][old_col], 0
    %{board: board, wallet: (if move_to == 3, do: wallet + 1, else: wallet)}
    |> GameData.set
    # Move or don't move according to the collision check
    unless (Enum.member?([1, nil], move_to)), do: new_pos, else: old_pos
  end

  def handle_cast(:move_left, state) do
    {row, col} = state
    {:noreply,  move({row, col}, {row, col - 1}, state)}
  end

  def handle_cast(:move_right, state) do
    {row, col} = state
    {:noreply, move({row, col}, {row, col + 1}, state)}
  end

  def handle_cast(:move_up, state) do
    {row, col} = state
    {:noreply, move({row, col}, {row - 1, col}, state)}
  end

  def handle_cast(:move_down, state) do
    {row, col} = state
    {:noreply, move({row, col}, {row + 1, col}, state)}
  end

  def state, do: GenServer.call(__MODULE__, :state)

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def move(:left), do: GenServer.cast(__MODULE__, :move_left)
  def move(:right), do: GenServer.cast(__MODULE__, :move_right)
  def move(:up), do: GenServer.cast(__MODULE__, :move_up)
  def move(:down), do: GenServer.cast(__MODULE__, :move_down)
end
