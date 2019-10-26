# Tapestry_Algorithm
Distributed Operating System - Project 3    

## Problem Definition  

To implement the Network Join and Routing as described in the Tapestry paper  
https://pdos.csail.mit.edu/~strib/docs/tapestry/tapestry_jsac03.pdf  

### Team Members:  
Sanchit Deora(8909 - 4939)  
Rohit Devulapalli (4787- 4434)
 
### What is working?    
This is a P2P Tapestry Protocol implemented in Elixir. In our implementation, we are building a tapestry network and successfully routing from each node in the list (‘numNodes’), ‘numRequests’ times and printing the maximum number of hops across all nodes in the network.  

### Largest Network of nodes  
The largest network that we ran our code on was for 5000 nodes and 10 requests for each peer.  

C:\...\tapestry_algorithm> mix run project3.exs 5000 10  
5

### Instructions to run the code:  
mix run project3.exs numNodes numRequests.  
This command is for Windows OS.    

Output prints the Maximum number of hops made in the network.
