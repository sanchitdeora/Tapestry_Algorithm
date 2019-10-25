defmodule Tapestry do

  def assignID(numNodes) do
    #    GENERATE NODE ID HERE
    list_ids = Enum.map(0..(numNodes - 1), fn x ->
      id = :erlang.crc32(Integer.to_string(x)) |> Integer.to_string(16)
      if(String.length(id) < 8) do
        zero = Enum.map(1..(8 - String.length(id)), fn x ->
          0
        end)
        id = Enum.join(zero,"") <> id
      else
        id
      end
    end)
    nodeList = List.flatten(list_ids)
  end

  def createNetwork(nodeList1) do

    node_ids1 = Enum.map(nodeList1, fn current_node ->
      PeerNode.start_link([name: current_node])
    end)

    Enum.map(nodeList1, fn current_node ->
      Enum.map(List.delete(nodeList1, current_node), fn other_node ->
        PeerNode.createNeighborMap(current_node, {current_node, other_node})
      end)
    end)

  end

  def joinNetwork(nodeList2, nodeList1) do
    node_ids2 = Enum.map(nodeList2, fn current_node ->
      PeerNode.start_link([name: current_node])
    end)

    neighborTuple = Enum.map(nodeList2, fn current_node ->
      PeerNode.join(current_node,{current_node, nodeList1, nodeList2})
#      findNearestNeighbor(current_node, nodeList1)
    end)
#    IO.inspect(neighborTuple)

  end



  def findNearestNeighbor(current_node, nodeList1) do
    prefix_indices = Enum.map(nodeList1, fn other_node ->
      longestprefix(Atom.to_string(current_node), Atom.to_string(other_node), 0)
    end)
#    IO.inspect(prefix_indices)

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
    {neighbors, max}
#    IO.inspect(neighbors, label: "#{current_node}")
  end

  def longestprefix(current_node, other_node, ind) do
    elem1 = String.at(current_node,ind)
    elem2 = String.at(other_node,ind)
    if elem1 == elem2 do
      longestprefix(current_node, other_node, ind + 1)
    else
      ind
    end

  end

  def findNeighbors(current, nodeList) do
    current = Atom.to_string(current)
    {:ok, <<a1,a2,_,_>>} = Base.decode16(current)

    Enum.map(nodeList, fn x ->
      other_node = Atom.to_string(x)
#      IO.inspect([current | other_node], label: "current and othernode")
      {:ok, <<b1,b2,_,_>>} = Base.decode16(other_node)

#      IO.inspect([a1 | b1], label: "a1 and b1")
      if abs(a1-b1) <= 20 do
        x
      else
        []
      end
    end)
  end

  def startRouting(nodeList, numRequests) do

    Enum.map(1..numRequests, fn x ->
      Enum.map(nodeList, fn sender ->
        receiver = Enum.random(List.delete(nodeList, sender))
#        IO.inspect([sender | receiver], label: "STARTING TO ROUTE")
        PeerNode.sendMessage(sender, {sender, sender, receiver, 0})
      end)
    end)
  end














  def generateID(numNodes) do
    list_ids = Enum.map(0..(numNodes - 1), fn x ->
      :crypto.strong_rand_bytes(4) |> Base.encode16()
    end)
    list_ids = ["F1785BD3", "80E4CFE1", "F1785BD3", "40C094D0", "502A0F3D"]
    list_ids = Enum.uniq(list_ids)
    IO.inspect(list_ids, label: "#{length(list_ids)}")
    list_ids = uniqueID(list_ids, numNodes)
    IO.inspect(list_ids)
  end

  def uniqueID(list_ids, numNodes) when length(list_ids) == numNodes do
    IO.inspect([numNodes | length(list_ids)],label: "now here its equal")
    list_ids
  end

  def uniqueID(list_ids, numNodes) do
    IO.inspect([numNodes | length(list_ids)],label: "now here its UNEQUAL")
    remaining = numNodes - length(list_ids)
    new_ids = Enum.map(0..(remaining - 1), fn x ->
      :crypto.strong_rand_bytes(4) |> Base.encode16()
    end)
    IO.inspect(new_ids, label: "newID")
    list_ids = list_ids ++ new_ids
    IO.inspect(list_ids, label: "new LIST ID")
    list_ids = Enum.uniq(list_ids)
    list_ids = uniqueID(list_ids, numNodes)
  end

end
