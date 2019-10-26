defmodule Tapestry do

#  Assigns Unique 8-digit Hex code
  def assignID(numNodes) do
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

#  Starts Creating Network for Tapestry
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

#  Dynamically Joins Nodes in the network
  def joinNetwork(nodeList2, nodeList1) do
    node_ids2 = Enum.map(nodeList2, fn current_node ->
      PeerNode.start_link([name: current_node])
    end)

    Enum.map(nodeList2, fn current_node ->
      PeerNode.join(current_node,{current_node, nodeList1, nodeList2})
    end)
  end

#  Starts Routing the Network
  def startRouting(numRequests) do
    nodeList = Listener.getNodeList(MyListener)
    Enum.map(1..numRequests, fn x ->
      Enum.map(nodeList, fn sender ->
        receiver = Enum.random(List.delete(nodeList, sender))
        PeerNode.sendMessage(sender, {sender, sender, receiver, 0})
      end)
    end)
  end

end
