# PeerNode GenServer

defmodule PeerNode do
  use GenServer

  #  CLIENT SIDE
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def setNeighbors(server, args) do
    GenServer.cast(server, {:setNeighbors, args})
  end

  def deleteNeighbors(server, args) do
    GenServer.cast(server, {:deleteNeighbors, args})
  end

  def createNeighborMap(server, args) do
    GenServer.cast(server, {:createNeighborMap, args})
  end

  def joinNeighborMap(server, args) do
    GenServer.cast(server, {:joinNeighborMap, args})
  end

  def updateNeighborMap(server, args) do
    GenServer.cast(server, {:updateNeighborMap, args})
  end

  def join(server, args) do
    GenServer.cast(server, {:join, args})
  end

  def multicast(server, args) do
    GenServer.cast(server, {:multicast, args})
  end

  def sendMessage(server, args) do
    GenServer.cast(server, {:sendMessage, args})
  end

  def fail(server, args) do
    GenServer.cast(server, {:fail, args})
  end

  def deleteFromNeighborMap(server, args) do
    GenServer.cast(server, {:deleteFromNeighborMap, args})
  end

  def getNeighborList(server) do
    GenServer.call(server, {:getNeighborList})
  end

  def getNeighborMap(server) do
    GenServer.call(server, {:getNeighborMap})
  end

  def prefixCheck(server, args) do
    {server, str1, str2, i} = args
    elem1 = String.at(str1, i)
    elem2 = String.at(str2, i)
    if elem1 == elem2 do
      prefixCheck(server, {server, str1, str2, i + 1})
    else
      i
    end
  end

  def findNearestNeighbor(server, args) do
    {server, nodeList1} = args
    server_string = Atom.to_string(server)
    prefix_indices = Enum.map(nodeList1, fn other_node ->
      node_string = Atom.to_string(other_node)
      prefixCheck(server, {server, server_string, node_string, 0})
    end)

    max = Enum.max(prefix_indices)
    neighborIndex =
      Enum.map(0..(length(nodeList1) - 1), fn x ->
        if Enum.at(prefix_indices, x) == max do
          x
        else
          []
        end
      end)
    neighborIndex = List.flatten(neighborIndex)
    neighbors = Enum.map(neighborIndex, fn ind ->
      Enum.at(nodeList1, ind)
    end)
    neighbor_tuple = {neighbors, max}
    end


    #  SERVER SIDE
  def init(:ok) do
    {:ok,
      %{:L0 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]], :L1 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],
        :L2 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]], :L3 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],
        :L4 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]], :L5 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],
        :L6 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]], :L7 => [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],
        :neighbors => []}
    }
  end

  def handle_cast({:createNeighborMap, args}, state) do
    {server, other_node} = args
    server_string = Atom.to_string(server)
    node_string = Atom.to_string(other_node)
    ind = prefixCheck(server, {server, server_string, node_string, 0})
    row = ("L" <> Integer.to_string(ind)) |> String.to_atom()
    col = String.at(node_string, ind) |> Utility.hexToDec()
    levelList = Map.fetch!(state, row)
    existingval = Enum.at(levelList,col)
    value = if existingval == [] do
      setNeighbors(server, {server, other_node})
      [other_node]
      else
        closerNode = Utility.closerHash(server, Enum.at(existingval, 0), other_node)
        if closerNode == other_node do
           deleteNeighbors(server, {server, Enum.at(existingval, 0)})
           setNeighbors(server, {server, other_node})
        end
        [other_node] ++ existingval
    end
    levelList = List.delete_at(levelList, col)
    levelList = List.insert_at(levelList, col, value)
    state = Map.replace!(state, row, levelList)

    {:noreply, state}
  end

  def handle_cast({:updateNeighborMap, args}, state) do
    {server, neighbor_node, ind} = args
    row = ("L" <> Integer.to_string(ind)) |> String.to_atom()
    node_string = Atom.to_string(neighbor_node)
    col = String.at(node_string, ind) |> Utility.hexToDec()

    levelList = Map.fetch!(state, row)
    existingval = Enum.at(levelList,col)
    value = if existingval == [] do
      [neighbor_node]
    else
      [neighbor_node] ++ existingval
    end
    levelList = List.delete_at(levelList, col)
    levelList = List.insert_at(levelList, col, value)
    state = Map.replace!(state, row, levelList)
    setNeighbors(server, {server, neighbor_node})
    {:noreply, state}
  end




  def handle_cast({:setNeighbors, args}, state) do

    {server, neighbor_node} = args
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = neighbors ++ [neighbor_node]

    state = Map.replace!(state, :neighbors, neighbors)
    {:noreply, state}
  end

  def handle_cast({:deleteNeighbors, args}, state) do

    {server, neighbor_node} = args
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = neighbors -- [neighbor_node]
    state = Map.replace!(state, :neighbors, neighbors)
    {:noreply, state}
  end

  def handle_cast({:joinNeighborMap, args}, state) do
    {server, neighbors} = args
    temp_neighbor = List.first(neighbors)
    tempMap = PeerNode.getNeighborMap(temp_neighbor)
    state = tempMap
    {:noreply, state}
  end

  def handle_cast({:join, args}, state) do
    {server, nodeList1, nodeList2} = args
    neighbor_tuple = findNearestNeighbor(server, {server, nodeList1})

    {neighbors, max} = neighbor_tuple
    PeerNode.joinNeighborMap(server, {server, neighbors})

    updateNeighborMap(server, {server, List.first(neighbors), max})
    PeerNode.multicast(server, {server, neighbors, max})
    {:noreply, state}
  end

  def handle_cast({:multicast, args}, state) do
#    Send Neighbors Multicast to update Routing
    {server, neighbors, max} = args
    Enum.each(neighbors, fn neighbor_node ->
      PeerNode.updateNeighborMap(neighbor_node, {neighbor_node, server, max})
    end)
    {:noreply, state}
  end

  def handle_cast({:sendMessage, args}, state) do
    {server, sender, receiver, hops} = args
    if server == receiver do
      Listener.setHops(MyListener, hops)

      {:noreply, state}
    else
      neighbors = Map.fetch!(state, :neighbors)

      prefix_index = prefixCheck(server, {server, Atom.to_string(server), Atom.to_string(receiver), 0})
      prefix = String.at(Atom.to_string(receiver), prefix_index)
      prefix = Utility.hexToDec(prefix)

      level = "L" <> Integer.to_string(prefix_index) |> String.to_atom()
      levelList = Map.fetch!(state, level)
      next_node = Enum.at(levelList, prefix)
      if next_node == nil or next_node == [] do
        threshold = Listener.getThreshold(MyListener)
        Listener.setThreshold(MyListener, threshold - 1)
      else
        PeerNode.sendMessage(Enum.at(next_node,0), {Enum.at(next_node,0), sender, receiver, (hops + 1)})
      end
    end

    {:noreply, state}
  end

  def handle_cast({:fail, args}, state) do
    {server, numRequests} = args
    nodeList = Listener.getNodeList(MyListener)
    nodeList = List.delete(nodeList, server)
    Listener.setNodeList(MyListener, nodeList)

    threshold = Listener.getThreshold(MyListener)
    Listener.setThreshold(MyListener, threshold - numRequests)

    Enum.each(nodeList, fn x ->
      PeerNode.deleteNeighbors(x, {x, server})
      Enum.each(0..7, fn i ->
        PeerNode.deleteFromNeighborMap(x, {x, i, server})
      end)

    end)
    {:noreply, state}
  end

  def handle_cast({:deleteFromNeighborMap, args}, state) do
    {server, col_index, failedNode} = args

      level = ("L" <> Integer.to_string(col_index)) |> String.to_atom()
      levelList = Map.fetch!(state, level)
      levelList = levelList -- [[failedNode]]
      state = Map.replace!(state, level, levelList)

    {:noreply, state}
  end

  def handle_call({:getNeighborMap}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:getNeighborList}, _from, state) do
    neighbors = Map.fetch!(state, :neighbors)
    {:reply, neighbors, state}
  end

end