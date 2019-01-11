defmodule PtermTest do
  use ExUnit.Case
  doctest Pterm

  test "greets the world" do
    assert Pterm.hello() == :world
  end
end
