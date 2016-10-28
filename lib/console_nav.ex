defmodule ConsoleNav do
  defmodule Matrix do
    @moduledoc """
    Helpers for working with multidimensional lists, also called matrices.
    """

    @doc """
    Converts a multidimensional list into a zero-indexed map.

    ## Example

        iex> list = [["x", "o", "x"]]
        ...> Matrix.from_list(list)
        %{0 => %{0 => "x", 1 => "o", 2 => "x"}}
    """
    def from_list(list) when is_list(list) do
      do_from_list(list)
    end

    defp do_from_list(list, map \\ %{}, index \\ 0)
    defp do_from_list([], map, _index), do: map
    defp do_from_list([h|t], map, index) do
      map = Map.put(map, index, do_from_list(h))
      do_from_list(t, map, index + 1)
    end
    defp do_from_list(other, _, _), do: other

    @doc """
    Converts a zero-indexed map into a multidimensional list.

    ## Example

        iex> matrix = %{0 => %{0 => "x", 1 => "o", 2 => "x"}}
        ...> Matrix.to_list(matrix)
        [["x", "o", "x"]]
    """
    def to_list(matrix) when is_map(matrix) do
      do_to_list(matrix)
    end

    defp do_to_list(matrix) when is_map(matrix) do
      for {_index, value} <- matrix,
          into: [],
          do: do_to_list(value)
    end
    defp do_to_list(other), do: other
  end

  defmodule Board do
    use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, [])
    end

    def init(map) do
      map = [
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
      {:ok, map}
    end

    def move(pid, :left), do: GenServer.call(pid, :move_left)
    def move(pid, :right), do: GenServer.call(pid, :move_right)
    def move(pid, :up), do: GenServer.call(pid, :move_up)
    def move(pid, :down), do: GenServer.call(pid, :move_down)
    def draw(pid), do: GenServer.call(pid, :draw)

    defp player_in_row(row) do
      Map.values(row) |> Enum.member?(2)
    end

    defp player_location(map) do
      len = Enum.count(map) - 1
      Enum.map(0..len, fn(i) ->
        if player_in_row(map[i]) do
          row = i
          col = Enum.find_index(map[row], fn {key, val} -> val == 2 end)
          {row , col}
        end
      end)
      |> Enum.max
    end

    def handle_call(:move_left, _from,  map) do
      {row, col} = player_location(map)
      new_map = map
      unless map[row][col - 1] == 1 do
        new_map = put_in new_map[row][col], 0
        new_map = put_in new_map[row][col - 1], 2
      end
      {:reply, map, new_map}
    end

    def handle_call(:move_right, _from,  map) do
      {row, col} = player_location(map)
      new_map = map
      unless map[row][col + 1] == 1 do
        new_map = put_in new_map[row][col], 0
        new_map = put_in new_map[row][col + 1], 2
      end
      {:reply, map, new_map}
    end

    def handle_call(:move_up, _from,  map) do
      {row, col} = player_location(map)
      new_map = map
      unless map[row - 1][col] == 1 do
        new_map = put_in new_map[row][col], 0
        new_map = put_in new_map[row - 1][col], 2
      end
      {:reply, map, new_map}
    end

    def handle_call(:move_down, _from, map) do
      {row, col} = player_location(map)
      new_map = map
      unless map[row + 1][col] == 1 do
        new_map = put_in new_map[row][col], 0
        new_map = put_in new_map[row + 1][col], 2
      end
      {:reply, map, new_map}
    end

    def handle_call(:draw, _from, map) do
      clear_map
      map
      |> Matrix.to_list
      |> Enum.each(fn(y) ->
        IO.write "\e[2K\r"
        IO.inspect y
      end)
      {:reply, map, map}
    end

    defp clear_map do
      IO.puts "\e[2J"
      IO.puts "\e[0;0H"
    end

  end
  defmodule CLI do
    use GenServer

    def start_link(game) do
      GenServer.start_link(ConsoleNav.CLI, game)
    end

    def init(game) do
      port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
      state = %{
        port: port,
        game: game
      }
      IO.puts "\e[?25l" # hide cursor
      # puts "\e[?25h" # show cursor
      clear_screen
      {:ok, state}
    end

    def handle_info({_pid, {:data, data}}, state) do
      translate(data)
      |> handle_key(state)
      ConsoleNav.Board.draw(state.game)
      {:noreply, state}
    end

    # terminal control escape sequences
    defp translate("\e[A"), do: :move_up
    defp translate("\e[B"), do: :move_down
    defp translate("\e[C"), do: :move_right
    defp translate("\e[D"), do: :move_left
    defp translate(_),      do: nil

    defp handle_key(nil), do: :ok
    defp handle_key(key, state) do
      game = state.game
      case key do
        :move_up ->
          ConsoleNav.Board.move(game, :up)
        :move_down ->
          ConsoleNav.Board.move(game, :down)
        :move_right ->
          ConsoleNav.Board.move(game, :right)
        :move_left ->
          ConsoleNav.Board.move(game, :left)
      end
    end

    defp clear_screen do
      # erase screen
      IO.puts "\e[2J"
      # reset cursor position
      IO.puts "\e[0;0H"
    end
  end

  def main(_args) do
    {:ok, game} = __MODULE__.Board.start_link
    __MODULE__.CLI.start_link(game)
    setup_board(game)
    :erlang.hibernate(Kernel, :exit, [:killed])
  end

  defp setup_board(pid) do
    __MODULE__.Board.draw(pid)
  end
end
