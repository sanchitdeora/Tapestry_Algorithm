defmodule Proj3 do

  [numNodes, numRequests] = System.argv
  {numNodes, _} = Integer.parse(numNodes)
  {numRequests, _} = Integer.parse(numRequests)

  #  Set Threshold
  threshold = numNodes * numRequests

  #  Split Nodes to create network and join remaining nodes
  num1 = numNodes * 0.8 |> :erlang.trunc
  num2 = numNodes - num1

  Process.register(self(), Main)

  #  Start Listener and Set Threshold
  {:ok, listener} = Listener.start_link(name: MyListener)
  Listener.setThreshold(MyListener, threshold)

  {:ok, master} = Master.start_link(name: MyMaster)
  Master.failNodes(master, {numNodes, numRequests})

  #  Generates 8 digit Hex Node Ids and convert to Atom
  nodeList = Tapestry.assignID(numNodes)
  #  IO.inspect(nodeList)
  nodeList = Enum.map(nodeList, fn x -> String.to_atom(x) end)
  Listener.setNodeList(MyListener, nodeList)

  #  Split List of Nodes in two for Creating and Joining Network
  nodeList1 = Enum.slice(nodeList, 0..(num1 - 1))

  #  Create Network with Node List 1
  Tapestry.createNetwork(nodeList1)

  #  Join Nodes in Network in Node List 2
  nodeList2 = nodeList -- nodeList1
  IO.inspect(nodeList1, label: "nodeList1")
  IO.inspect(nodeList2, label: "nodeList2")

  Tapestry.joinNetwork(nodeList2, nodeList1)

  Enum.map(nodeList, fn x ->
    state_after_exec = :sys.get_state(x, :infinity)
    Process.sleep(1)
    #    state = PeerNode.getNeighborMap(x)
    #    neighbors = Map.fetch!(state, :neighbors)
    #    IO.inspect(state, label: "Final Server #{x}")
  end)

  IO.inspect("Network Created")

  IO.inspect("Start Routing")
  Tapestry.startRouting(numRequests)

  #  state1 = PeerNode.getNeighborMap(:AB2DE132)
  #  IO.inspect(state1)


  #  Waits for the Routing to get done
  receive do
    {:done} ->
      hops = Listener.getHops(MyListener)
      nodeList = Listener.getNodeList(MyListener)
      max = Enum.max(hops)
      IO.inspect(hops, label: "Max Hop = #{max} from Hops")
    #      Enum.each(nodeList, fn x -> IO.puts(Atom.to_string(x)) end)
    #      IO.inspect(nodeList, label: "Final NodeList")

#      Process.sleep(0000)
      Enum.map(nodeList, fn x ->
        state_after_exec = :sys.get_state(x, :infinity)
        Process.sleep(1)
        state = PeerNode.getNeighborMap(x)
        neighbors = Map.fetch!(state, :neighbors)
#        IO.inspect(state, label: "Final Server #{x}")
      end)

  end

end