defmodule Proj3 do
  numNodes = 10
  numRequests = 2

  num1 = numNodes * 0.8 |> :erlang.trunc
  num2 = numNodes - num1

  nodeList = Tapestry.assignID(numNodes)
#  nodeList = ["1240", "A320", "1320", "F135", "A738"]
  IO.inspect(nodeList)
  nodeList = Enum.map(nodeList, fn x -> String.to_atom(x) end)

  nodeList1 = Enum.slice(nodeList, 0..(num1 - 1))
  nodeList2 = nodeList -- nodeList1

  IO.inspect(nodeList1, label: "nodeList1")
  IO.inspect(nodeList2, label: "nodeList2")

# Create Network with Node List 1
  Tapestry.createNetwork(nodeList1)

# Join Nodes in Network in Node List 2
  Tapestry.joinNetwork(nodeList2, nodeList1)

  Enum.map(nodeList, fn x ->
    state_after_exec = :sys.get_state(x, :infinity)
    Process.sleep(1)
    state = PeerNode.getNeighborMap(x)
    neighbors = Map.fetch!(state, :neighbors)
    IO.inspect(state, label: "Final Server #{x}")
  end)

  IO.inspect("Network Created")
  IO.inspect("Start Routing")

  Tapestry.startRouting(nodeList, numRequests)




  Enum.map(nodeList, fn x ->
    state_after_exec = :sys.get_state(x, :infinity)
    Process.sleep(1)
    state = PeerNode.getNeighborMap(x)
    neighbors = Map.fetch!(state, :neighbors)
#    IO.inspect(state, label: "Final Server #{x}")
  end)
#  IO.inspect(node_ids)

#  neighbors = Enum.map(nodeList, fn x ->
#    StartProcess.findNeighbors(x, List.delete(nodeList,x))
#  end)
#
#  IO.inspect(neighbors, label: "NEIGHBORSSSSSSSSSSSSSSSSSSSSS")

#  Enum.map(nodeList, fn x ->
#    PeerNode.setNeighborMap(x, {x, List.delete(nodeList, x)})
#  end)

end