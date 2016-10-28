defmodule ConsoleNav do
  defmodule Matrix do
    @moduledoc """
    Helpers for working with multidimensional lists, also called matrices.
    """

    @doc """
    Converts a multidimensional list into a zero-indexed board.

    ## Example

        iex> list = [["x", "o", "x"]]
        ...> Matrix.from_list(list)
        %{0 => %{0 => "x", 1 => "o", 2 => "x"}}
    """
    def from_list(list) when is_list(list) do
      do_from_list(list)
    end

    defp do_from_list(list, board \\ %{}, index \\ 0)
    defp do_from_list([], board, _index), do: board
    defp do_from_list([h|t], board, index) do
      board = Map.put(board, index, do_from_list(h))
      do_from_list(t, board, index + 1)
    end
    defp do_from_list(other, _, _), do: other

    @doc """
    Converts a zero-indexed board into a multidimensional list.

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

    def init(board) do
      board = [
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
      {:ok, board}
    end

    def move(pid, :left), do: GenServer.cast(pid, :move_left)
    def move(pid, :right), do: GenServer.cast(pid, :move_right)
    def move(pid, :up), do: GenServer.cast(pid, :move_up)
    def move(pid, :down), do: GenServer.cast(pid, :move_down)
    def draw(pid), do: GenServer.call(pid, :draw)

    defp player_in_row(row) do
      Map.values(row) |> Enum.member?(2)
    end

    defp player_location(board) do
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

    defp move_player(old_pos, new_pos, board) do
      {old_row, old_col} = old_pos
      {new_row, new_col} = new_pos
      unless board[new_row][new_col] == 1 do
        board = put_in board[old_row][old_col], 0
        board = put_in board[new_row][new_col], 2
      end
      board
    end

    def handle_cast(:move_left, board) do
      {row, col} = player_location(board)
      {:noreply,  move_player({row, col}, {row, col - 1}, board)}
    end

    def handle_cast(:move_right, board) do
      {row, col} = player_location(board)
      {:noreply, move_player({row, col}, {row, col + 1}, board)}
    end

    def handle_cast(:move_up, board) do
      {row, col} = player_location(board)
      {:noreply, move_player({row, col}, {row - 1, col}, board)}
    end

    def handle_cast(:move_down, board) do
      {row, col} = player_location(board)
      {:noreply, move_player({row, col}, {row + 1, col}, board)}
    end

    def handle_call(:draw, _from, board) do
      clear_board
      board
      |> Matrix.to_list
      |> Enum.each(fn(row) ->
        IO.write "#{IO.ANSI.clear_line}\r"
        IO.inspect row
      end)
      {:reply, board, board}
    end

    defp clear_board do
      IO.write IO.ANSI.clear
      IO.write IO.ANSI.home
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
      {:ok, state}
    end

    def handle_info({_pid, {:data, data}}, state) do
      translate(data)
      |> handle_key(state)
      ConsoleNav.Board.draw(state.game)
      {:noreply, state}
    end

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
