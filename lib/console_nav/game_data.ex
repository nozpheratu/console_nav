defmodule ConsoleNav.GameData do
  use GenServer
  alias ConsoleNav.Matrix

  ####################
  ##### Legend #######
  ####################
  # 0: empty
  # 1: wall
  # 2: player
  # 3: coin
  @initial_board [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ]

  def start(board \\ @initial_board) do
    board = add_coins(board, 0)
    state = %{board: Matrix.from_list(board), wallet: 0}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_cast({:set, assigned_state}, state) do
    {:noreply, Map.merge(state, assigned_state)}
  end

  defp add_coins(board, sanity) do
    attempt = board
    |> Enum.map(fn(row) -> Enum.map(row, &generate_coins/1) end)
    count = count_coins(attempt)
    if(sanity > 10000 || enough_coins?(count), do: attempt, else: add_coins(board, sanity + 1))
  end

  defp count_coins(board) do
    Enum.flat_map(board, &(&1))
    |> List.foldl(0, fn(x, acc) -> if(x == 3, do: acc + 1, else: acc) end)
  end

  defp enough_coins?(count) do
    count >= 5 && count <= 12
  end

  defp generate_coins(col) do
    if(col == 0 && Enum.random(1..100) > 95, do: Enum.random([col, 3]), else: col)
  end
end
