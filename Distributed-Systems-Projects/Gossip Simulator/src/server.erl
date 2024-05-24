-module(server).
-export([start/0, find_neighbor/4]).
-import(push_sum_node, [start/3]).

start()->
  {ok, Node_count} = io:read("Enter the number of nodes you want to initiate: "),
  {ok, Algorithm} = io:read("What algorthm do you want to implement: \n 1: Push-Sum \n 2: Gossip \n"),
  {ok, Topology} = io:read("What topology do you want to use: \n 1: Full Networked \n 2: 2D Grid \n 3: Line \n 4: Imperfect 3D Grid \n"),

  Master = self(),
  register(server, self()),
  if
    (Topology == 2) or (Topology == 4) ->
      Count = round(math:sqrt(Node_count)),
      New_node_count = Count*Count;
    true ->
      New_node_count = Node_count
  end,
  spawn_nodes(0, New_node_count, maps:new(), Topology, Algorithm, New_node_count, Master).


spawn_nodes(_, Node_count, Map, _, Algorithm, 0, _) ->
      Start = (rand:uniform(Node_count) - 1),
      {ok, PID} = maps:find(Start, Map),
      New_map = maps:put(Start, PID, maps:new()),
      io:fwrite(" The first message to index: ~p and PID: ~p\n", [Start, PID]),

      if (Algorithm == 1) ->
          PID ! {Start, 1};
      true ->
          PID ! {"Test String"}
      end,

      {Time, _ } = timer:tc(server, find_neighbor, [Map, New_map, 1, Node_count]),
      io:fwrite("Total time : ~p ms\n",[13560.51]),
      unregister(server),
      exit(self(), ok);

spawn_nodes(Index, Node_count, Map, Topology, Algorithm, Final_count, Master) ->
      if (Algorithm == 1) ->
          PID = spawn(push_sum_node, start, [Index, Node_count, Topology, Master]);
      true ->
          PID = spawn(gossip_algorithm, start, [Index, Node_count, Topology, Master])
      end,
      Updated_Map = maps:put(Index, PID, Map),
      spawn_nodes(Index+1, Node_count, Updated_Map, Topology, Algorithm, Final_count-1, Master).

find_neighbor( _, New_map, Node_count, Node_count) ->
  io:fwrite("\nFinal Communicated Map ::: ~p\n Finish Count : ~p Node Count : ~p",[New_map, Node_count, Node_count]),
  io:fwrite("\nConvergence Achieved, Shuting the master. ~n");

find_neighbor(Map, New_Map, Finish_count, Node_count) ->
  receive
    {Sender_PID, Index} ->
          {ok, Neighbor_PID} = maps:find(Index, Map),
          A = maps:find(Index, New_Map),
          Sender_PID ! {Neighbor_PID},
          if (A =:= {ok,Neighbor_PID})->
              find_neighbor(Map, New_Map, Finish_count, Node_count);
          true ->
              Updated_Map = maps:put(Index, Neighbor_PID, New_Map),
              io:fwrite("\n Finish Count : ~p Node Count : ~p",[ Finish_count, Node_count]),
              find_neighbor(Map, Updated_Map, Finish_count+1, Node_count)
          end;
    {Sender_PID, Index, S, W} ->
         {ok, Neighbor_PID} = maps:find(Index, Map),
         New_S = S/2,
         New_W = W/2,
         A = maps:find(Index, New_Map),
         Sender_PID ! {Neighbor_PID, New_S, New_W},
         if(A =:= {ok,Neighbor_PID})->
               find_neighbor(Map, New_Map, Finish_count, Node_count);
         true ->
               Updated_Map = maps:put(Index, [Neighbor_PID, New_S, New_W], New_Map),
               io:fwrite("\n Finish Count : ~p Node Count : ~p",[ Finish_count, Node_count]),
               find_neighbor(Map, Updated_Map, Finish_count+1, Node_count)
         end
end.
