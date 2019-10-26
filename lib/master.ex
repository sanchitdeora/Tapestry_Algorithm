# Master GenServer

defmodule Master do
    use GenServer

    # CLIENT SIDE
    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def failNodes(server, args) do
        GenServer.cast(server, {:failNodes, args})
    end

    # SERVER SIDE
    def init(:ok) do
        {:ok, []}
    end

    def handle_cast({:failNodes, args}, state) do
        {numNodes, numRequests} = args

        # Master sleeps for 0 - 2000ms after initiation, before it starts to fail nodes
        :timer.sleep(:rand.uniform(2000))
        IO.puts("Start Failing Nodes !!!")

        nodeList = Listener.getNodeList(MyListener)

        # failFactor decides the number of nodes to be failed in the network
        failFactor = 0.1
        toBeFailed = length(nodeList) * failFactor |> trunc

        # Nodes chosen to be failed at random
        failingNodes = Enum.map(0..toBeFailed-1, fn _i->
            Enum.random(nodeList)
        end)
        # Starting to fail nodes chosen
        Enum.each(failingNodes, fn fail_node ->

            PeerNode.fail(fail_node, {fail_node, numRequests})
        end)
        {:noreply, state}
    end
end