-module(topology).
-export([neighbor_list/4, start/3]).

add_random(Index, Node_count, List) ->
  RandomIndex = (rand:uniform(Node_count) - 1),
  Check_num = fun(E) -> E == RandomIndex end,
  Status = lists:any(Check_num, List),
  if ((Status== false) and (RandomIndex =/= Index)) ->
    RandomList = lists:append([List, [RandomIndex]]),
    RandomList;
  true ->
      add_random(Index, Node_count, List)
  end.

neighbor_list(Index, Topology, Node_count, List) ->
  shell:strings(false),
  case Topology of
    %Full Network
    1 ->
      if(Index>=Node_count) ->
        ok;
      true ->
        Neighbor=(rand:uniform(Node_count) - 1),
        if(Neighbor == Index) ->
            neighbor_list(Index, Topology, Node_count, List);
        true ->
            Neighbor_list = lists:append([List, [Neighbor]]),
            Neighbor_list
        end
      end;

    %2D Grid
    2 ->
        Num_rows = round(math:sqrt(Node_count)),
        if (Index >= Num_rows*Num_rows) ->
          ok;
        true ->
          X = (Index div Num_rows),
          Y = (Index rem Num_rows),

          if (Y == 0) ->
            Bottom_left=[],
            Left = [];
          true ->
            if(X == Num_rows-1) ->
              Bottom_left = [];
            true ->
              Bottom_left=[Index+Num_rows-1]
            end,
            Left = [Index-1]
          end,

          if (Y == Num_rows -1) ->
            Bottom_right=[],
            Right = [];
          true ->
            if(X == Num_rows-1) ->
              Bottom_right = [];
            true ->
              Bottom_right=[Index+Num_rows+1]
            end,
            Right = [Index+1]
          end,

          if (X == 0) ->
            Top_left=[],
            Top = [],
            Top_right=[];
          true ->
            if(Y == 0) ->
              Top_left=[];
             true->
               Top_left = [Index-Num_rows-1]
             end,

            if(Y == Num_rows-1) ->
              Top_right=[];
            true->
              Top_right = [Index-Num_rows+1]
            end,
            Top = [Index-Num_rows]
          end,

          if (X == Num_rows -1) ->
            Bottom = [];
          true ->
            Bottom = [Index+Num_rows]
          end,

        Neighbor_list = lists:append([List,Top_left,Top,Top_right,Left,Right,Bottom_left,Bottom,Bottom_right]),
        Neighbor_list
    end;

 %Line
  3 ->
    if(Index >= Node_count) ->
      ok;
    true ->
        if (Index == 0) ->
          Left = [];
        true ->
          Left = [Index -1]
        end,

        if (Index == Node_count-1) ->
          Right = [];
        true ->
          Right = [Index+1]
        end,

        NewList = lists:append([List, Left, Right]),
        NewList
    end;

  %Imperfect 3D
  4->
      Num_rows = round(math:sqrt(Node_count)),
      if (Index >= Num_rows*Num_rows) ->
        ok;
      true ->
          X = (Index div Num_rows),
          Y = (Index rem Num_rows),

          if (Y == 0) ->
            Bottom_left=[],
            Left = [];
          true ->
            if(X == Num_rows-1) ->
              Bottom_left = [];
            true ->
              Bottom_left=[Index+Num_rows-1]
            end,
            Left = [Index-1]
          end,

          if (Y == Num_rows -1) ->
            Bottom_right=[],
            Right = [];
          true ->
            if(X == Num_rows-1) ->
              Bottom_right = [];
            true ->
              Bottom_right=[Index+Num_rows+1]
            end,
            Right = [Index+1]
          end,

          if (X == 0) ->
            Top_left=[],
            Top = [],
            Top_right=[];
          true ->
            if(Y == 0) ->
              Top_left=[];
            true->
              Top_left = [Index-Num_rows-1]
            end,

            if(Y == Num_rows-1) ->
              Top_right=[];
            true->
              Top_right = [Index-Num_rows+1]
            end,
          Top = [Index-Num_rows]
          end,

          if (X == Num_rows -1) ->
            Bottom = [];
            true ->
            Bottom = [Index+Num_rows]
            end,

            Neighbor_list = lists:append([List,Top_left,Top,Top_right,Left,Right,Bottom_left,Bottom,Bottom_right]),
            Random_list = add_random(Index, Node_count, Neighbor_list),
            Random_list
          end
      end.


start(Topology, Index, NodeCount) -> % for testing
  neighbor_list(Index, Topology, NodeCount, []).

