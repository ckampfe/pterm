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

  # CALLBACKS
  ######################################

  def init(%{data: data} = _args) do
    {:ok, data}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
