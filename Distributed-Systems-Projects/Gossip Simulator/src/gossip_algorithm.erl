-module(gossip_algorithm).
-export([start/4]).
-export([pass_message_to_neighbours/5]).
-import(topology, [neighbor_list/4]).

start(Index, Node_count, Topology, Master) ->
  io:fwrite("~nStarted gossip-node with index: ~p",[Index]),
  curr_state(1, Index, Node_count, Topology, self(), Master).

curr_state(10,_,_,_,Sender_PID,_) ->
  exit(Sender_PID, ok);

curr_state(Rumor_count, Index, Node_count, Topology, Sender_PID, Master) ->
  receive
    {Rumor} ->
      if(Rumor_count == 1) ->
        New_Sender_PID = spawn(gossip_algorithm, pass_message_to_neighbours, [Index, Topology, Node_count, Rumor, Master]);
      true ->
        New_Sender_PID = Sender_PID,
        ok
      end,
      curr_state(Rumor_count+1, Index, Node_count, Topology, New_Sender_PID, Master)
  end.

pass_message_to_neighbours(Parent_index, Topology, Node_count, Rumor, Master) ->
  Neighbor_List = neighbor_list(Parent_index, Topology, Node_count, []),
  Random_neighbor = rand:uniform(length(Neighbor_List)),
  message_neighbor(Neighbor_List, Random_neighbor, Parent_index, Rumor, Master),
  pass_message_to_neighbours(Parent_index, Topology, Node_count, Rumor, Master).


message_neighbor(_, 0, _, _, _) ->
  ok;
message_neighbor(Neighbor_List, Neighbor_Index, Parent_Index, Rumor, Master) ->
  Neighbor = lists:nth(Neighbor_Index,Neighbor_List),
  Master_Alive = is_process_alive(Master),
  if( Master_Alive ) ->
    server ! {self(), Neighbor};
  true ->
    ok
  end,

  receive
    {Neighbor_PID} ->
      Neighbor_Alive = is_process_alive(Neighbor_PID),
      if( Neighbor_Alive ) ->
        io:fwrite("\n ~p sending rumor to ~p",[ Parent_Index, Neighbor]),
        Neighbor_PID ! {Rumor};
      true ->
        ok
      end
  end,
  message_neighbor(Neighbor_List, Neighbor_Index-1, Parent_Index, Rumor, Master).