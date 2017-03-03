defmodule NavigatorTest do
  use ExUnit.Case
  alias ConsoleNav.Navigator

  test "retrieving the position" do
    pos = {0,:rand.uniform(10)}
    {:ok, pid} = GenServer.start_link(Navigator, %{position: pos})
    assert pos == GenServer.call(pid, :position)
  end
end
