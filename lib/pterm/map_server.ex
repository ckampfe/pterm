defmodule Pterm.MapServer do

  use GenServer

  # PUBLIC
  ######################################

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def get(pid) do
    GenServer.call(pid, :get, 30_000)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # CALLBACKS
  ######################################

  def init(%{data: data} = _args) do
    {:ok, data}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get, key}, _from, state) do
    %{^key => val} = state
    {:reply, val, state}
  end
end
