# Listener GenServer

defmodule Listener do
  use GenServer

  #  CLIENT SIDE
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def setHops(server, args) do
    GenServer.call(server, {:setHops, args})
  end

  def setThreshold(server, args) do
    GenServer.call(server, {:setThreshold, args})
  end

  def getHops(server) do
    GenServer.call(server, {:getHops})
  end

  def getThreshold(server) do
    GenServer.call(server, {:getThreshold})
  end

  #  SERVER SIDE
  def init(:ok) do
    {:ok,
      %{:threshold => 0, :hops => []}
    }
  end

  def handle_call({:setThreshold, args}, from, state) do
    state = Map.replace!(state, :threshold, args)
    {:reply, state, state}
  end

  def handle_call({:setHops, args}, from, state) do
    hops = Map.fetch!(state, :hops)
    hops = hops ++ [args]
    state = Map.replace!(state, :hops, hops)
    threshold = Map.fetch!(state, :threshold)
    if(length(hops) == threshold) do
      send(Main, {:done})
    end
#    IO.inspect(state)
    {:reply, state, state}
  end

  def handle_call({:getHops}, from, state) do
    hops = Map.fetch!(state, :hops)
    {:reply, hops, state}
  end

  def handle_call({:getHops}, from, state) do
    threshold = Map.fetch!(state, :threshold)
    {:reply, threshold, state}
  end


end