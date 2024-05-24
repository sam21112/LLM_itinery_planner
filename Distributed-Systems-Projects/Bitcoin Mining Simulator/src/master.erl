%%Yash Goel - 51939756
%%Srikruth Reddy Puram - 70678514
-module(master).
-export([start/0, wait_for_miner/2]).
-import(string,[substr/3, right/3, concat/2]).

wait_for_miner(_, 100) ->
  ok;
wait_for_miner(Zeros, Coins) ->
          receive %% waiting for a miner to  connect
            { Miner_ID }->
                        io:fwrite("~n Incoming Connection Request"),
                        Miner_ID ! { Zeros },                       %% sending back the start string and number of zeros in hash
                        io:fwrite("~nRecived connection from: ~p ~n ~n", [Miner_ID]),
                        wait_for_miner(Zeros, Coins);                      %% waiting for another miner

            { String, Hash, Miner_ID} ->
                      io:fwrite("~p coins found, minted: ~p with hash: ~p from miner ~p\n", [Coins, String, Hash, Miner_ID]),
                      wait_for_miner(Zeros, Coins+1)
          end.


start() ->
        {ok, Zeros} = io:read("Number of 0s to mine: "),
        {ok, Miners} = io:read("Number of miners to spawn: "),
        spawn_many(self(), Zeros, Miners),
        register(master, self()),
        statistics(runtime),
        {Time, _} = timer:tc(master, wait_for_miner, [Zeros, 0]),
        {_, Time_CPU_Since_Last_Call} = statistics(runtime),
        io:fwrite("Total clock time: ~p\nToal CPU time ~p\n CPU time/ Run Time ~p\n", [Time/1000, Time_CPU_Since_Last_Call, Time_CPU_Since_Last_Call/(Time/1000)]),
        exit(self(), kill).


spawn_many(_, _, 0) ->
  ok;
spawn_many(Pid, Zeros, Miners) ->
  spawn(fun() -> start_mining(Pid, Zeros) end),
  spawn_many(Pid, Zeros, Miners-1).


start_mining(Pid, Zeros) ->                                                                            % start mining
  String=generate_random_string(),
  Hash = calculate_hash(String),
  Prefix = lists:concat(lists:duplicate(Zeros, "0")),
  Substring = substr(Hash, 1, Zeros),
  if
    Prefix == Substring ->
      Pid! {String, Hash, self()};
    true -> ok
  end,
  start_mining(Pid, Zeros).

generate_random_string() ->
  Base64_string =base64:encode(crypto:strong_rand_bytes(8)),
  Gen_string = binary_to_list(Base64_string),
  Final_string = string:join(["y.goel", Gen_string], ";"),
  Final_string.

calculate_hash(String) ->
  Hash = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256, String))]),
  Hash.
