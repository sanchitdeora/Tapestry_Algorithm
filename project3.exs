defmodule Project3 do

  [numNodes, numRequests] = System.argv
  {numNodes, _} = Integer.parse(numNodes)
  {numRequests, _} = Integer.parse(numRequests)

#  Set Threshold
  threshold = numNodes * numRequests

#  Split Nodes to create network and join remaining nodes
  num1 = numNodes * 0.8 |> :erlang.trunc

  Process.register(self(), Main)

#  Start Listener and Set Threshold
  Listener.start_link(name: MyListener)
  Listener.setThreshold(MyListener, threshold)

#  Generates 8 digit Hex Node Ids and convert to Atom
  nodeList = Tapestry.assignID(numNodes)
  nodeList = Enum.map(nodeList, fn x -> String.to_atom(x) end)
  Listener.setNodeList(MyListener, nodeList)

#  Split List of Nodes in two for Creating and Joining Network
  nodeList1 = Enum.slice(nodeList, 0..(num1 - 1))

#  Create Network with Node List 1
  Tapestry.createNetwork(nodeList1)

#  Join Nodes in Network in Node List 2
  nodeList2 = nodeList -- nodeList1

  Tapestry.joinNetwork(nodeList2, nodeList1)

  Enum.map(nodeList, fn x ->
    _state_after_exec = :sys.get_state(x, :infinity)
  end)

  IO.inspect("Network Created")
  IO.inspect("Start Routing")

  Tapestry.startRouting(numRequests)


#  Waits for the Routing to get done
  receive do

    {:done} ->
      hops = Listener.getHops(MyListener)
      max = Enum.max(hops)
      IO.inspect(hops, label: "Max Hop = #{max} from Hops")

    after 10000 ->
      IO.puts(:stderr, "No message in 10 seconds")
      hops = Listener.getHops(MyListener)
      max = Enum.max(hops)
      IO.inspect(hops, label: "Max Hop = #{max} from Hops")
  end

end