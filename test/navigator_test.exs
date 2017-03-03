defmodule NavigatorTest do
  use ExUnit.Case
  alias ConsoleNav.Navigator

  test "retrieving the position" do
    pos = {0,:rand.uniform(10)}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos})
    assert pos == GenServer.call(pid, :position)
  end

  test "move right" do
    pos = {0, 0}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos}, name: :test)
    {y, x} = GenServer.call(pid, :position)
    GenServer.cast(pid, :right)
    assert {y, x + 1} == GenServer.call(pid, :position)
  end

  test "move left" do
    pos = {0, 1}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos}, name: :test)
    {y, x} = GenServer.call(pid, :position)
    GenServer.cast(pid, :left)
    assert {y, x - 1} == GenServer.call(pid, :position)
  end

  test "move up" do
    pos = {1, 0}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos}, name: :test)
    {y, x} = GenServer.call(pid, :position)
    GenServer.cast(pid, :up)
    assert {y - 1, x} == GenServer.call(pid, :position)
  end

  test "move down" do
    pos = {0, 0}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos}, name: :test)
    {y, x} = GenServer.call(pid, :position)
    GenServer.cast(pid, :down)
    assert {y + 1, x} == GenServer.call(pid, :position)
  end

  test "can't move with a state of moving" do
    pos = {0, 0}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos, moving: true}, name: :test)
    {y, x} = GenServer.call(pid, :position)
    GenServer.cast(pid, :down)
    assert {0, 0} == GenServer.call(pid, :position)
  end
end
