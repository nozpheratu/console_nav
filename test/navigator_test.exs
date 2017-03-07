defmodule NavigatorTest do
  use ExUnit.Case
  alias ConsoleNav.Navigator
  alias ConsoleNav.GameData

  defp board do
    %{
      0 => %{0 => 0,1 => 0, 2 => 0},
      1 => %{0 => 0,1 => 0, 2 => 0},
      2 => %{0 => 0,1 => 0, 2 => 0}
    }
  end

  defp game do
    {:ok, pid} = GenServer.start_link(GameData, %{board: board})
    pid
  end

  defp navigator(pos \\ {0,0}, wallet \\ 0, game \\ game) do
    initial_state = %{position: pos, game: game, moving: false, wallet: 0}
    {:ok, player} = GenServer.start_link(Navigator, initial_state)
    player
  end

  test "retrieving the wallet" do
    player = navigator({0,0}, 0)
    assert 0 == GenServer.call(player, :wallet)
  end

  test "collecting a coin" do
    # 3 represents a coin
    board = %{
      0 => %{0 => 0, 1 => 3}
    }
    {:ok, game} = GenServer.start_link(GameData, %{board: board})
    player = navigator({0,0}, 0, game)
    assert 0 == GenServer.call(player, :wallet)
    GenServer.cast(player, :right)
    assert 1 == GenServer.call(player, :wallet)
  end

  test "retrieving the position" do
    pos = {0,:rand.uniform(10)}
    player = navigator(pos)
    assert pos == GenServer.call(player, :position)
  end

  test "move right" do
    player = navigator({0,0})
    {y, x} = GenServer.call(player, :position)
    GenServer.cast(player, :right)
    assert {y, x + 1} == GenServer.call(player, :position)
  end

  test "move left" do
    player = navigator({0,1})
    {y, x} = GenServer.call(player, :position)
    GenServer.cast(player, :left)
    assert {y, x - 1} == GenServer.call(player, :position)
  end

  test "move up" do
    player = navigator({1,0})
    {y, x} = GenServer.call(player, :position)
    GenServer.cast(player, :up)
    assert {y - 1, x} == GenServer.call(player, :position)
  end

  test "move down" do
    player = navigator({0,0})
    {y, x} = GenServer.call(player, :position)
    GenServer.cast(player, :down)
    assert {y + 1, x} == GenServer.call(player, :position)
  end
end
