-module(push_sum_algorithm).
-export([start/4, message_neighbor/7, pass_message_to_neighbour/6]).
-import(topology, [neighbor_list/4]).

start(Index, Node_count, Topology, Master) ->
  io:fwrite("~nStarted push-sum-node with index: ~p",[Index]),
  current_state(Index, Node_count, Topology, Master).


current_state(Index, Node_count, Topology, Master) ->
  receive
    {S, W} ->
        New_Sender_PID = spawn(push_sum_algorithm, pass_message_to_neighbour, [Index, Topology, Node_count, S, W, Master]),
        New_Sender_PID
  end.

pass_message_to_neighbour(Parent_index, Topology, Node_count, S, W, Master) ->
  Neighbor_List = neighbor_list(Parent_index, Topology, Node_count, []),
  Random_neighbor = rand:uniform(length(Neighbor_List)),
  message_neighbor(Neighbor_List, Random_neighbor, 0, Parent_index, S, W, Master).

get_time_stamp()->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega*1000000 + Sec)*1000 + (Micro/1000).

message_neighbor(_, _, 3, _, _, _, _) ->
  io:fwrite("Converged ~n"),
  io:fwrite("~p ~n",[get_time_stamp()]),
  ok;

message_neighbor(Neighbor_List, Neighbor_Index, Count, PID, Current_S, Current_W, Master) ->
  Neighbor = lists:nth(Neighbor_Index,Neighbor_List),
  Master_Alive = is_process_alive(Master),
  if( Master_Alive ) ->
    server ! {self(), Neighbor, Current_S, Current_W};
    true ->
      ok
  end,
  receive
    {Neighbor_PID, S, W} ->
      New_S = Current_S + S,
      New_W = Current_W + W,
      Previous_Ratio = Current_S / Current_W,
      New_Ratio = New_S / New_W,
      Neighbor_PID ! {PID, New_S / 2, New_W / 2},

      if abs(Previous_Ratio - New_Ratio) =< 0.0000000001 ->
        message_neighbor(Neighbor_List, Neighbor_Index, Count + 1, PID, New_S / 2, New_W / 2, Master);
        true ->
          message_neighbor(Neighbor_List, Neighbor_Index, 0, PID, New_S / 2, New_W / 2, Master)
      end
  end.

