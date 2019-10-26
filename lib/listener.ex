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

  def setNodeList(server, args) do
    GenServer.call(server, {:setNodeList, args})
  end

  def getNodeList(server) do
    GenServer.call(server, {:getNodeList})
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
      %{:threshold => 0, :nodeList => [], :hops => []}
    }
  end

  def handle_call({:setThreshold, args}, from, state) do
    state = Map.replace!(state, :threshold, args)
    hops = Map.fetch!(state, :hops)
    if(length(hops) == args) do
      send(Main, {:done})
    end
    {:reply, state, state}
  end

  def handle_call({:setNodeList, args}, from, state) do
    state = Map.replace!(state, :nodeList, args)
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
    {:reply, state, state}
  end

  def handle_call({:getThreshold}, from, state) do
    threshold = Map.fetch!(state, :threshold)
    {:reply, threshold, state}
  end

  def handle_call({:getNodeList}, from, state) do
    nodeList = Map.fetch!(state, :nodeList)
    {:reply, nodeList, state}
  end

  def handle_call({:getHops}, from, state) do
    hops = Map.fetch!(state, :hops)
    {:reply, hops, state}
  end
end