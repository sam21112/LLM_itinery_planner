%%Yash Goel - 51939756
%%Srikruth Reddy Puram - 70678514
-module(miner).
-import(string,[substr/3, right/3, concat/2]).
-export([start/0]).

start_mining(Zeros,IP_final) ->                                                                            % start mining
  String=generate_random_string(),
  Hash = calculate_hash(String),
  Prefix1 = lists:concat(lists:duplicate(Zeros, "0")),
  Prefix2 = lists:concat(lists:duplicate(Zeros+1, "0")),
  Substring = substr(Hash, 1, Zeros),
  if
    (Prefix1 == Substring) and (Prefix2 =/= Substring)->
      {master, IP_final} ! {String, Hash, self()};
    true -> ok
  end,
  start_mining(Zeros,IP_final).

generate_random_string() ->
    Base64_string =base64:encode(crypto:strong_rand_bytes(8)),
    Gen_string = binary_to_list(Base64_string),
    Final_string = string:join(["y.goel", Gen_string], ";"),
    Final_string.

calculate_hash(String) ->
  Hash = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256, String))]),
  Hash.

connect_to_master(IP_final) ->
        io:fwrite("~n Sending connection request to Master ~p", [IP_final]),
        {master, IP_final} ! {self()},
        receive
              { Zeros } ->
                      io:fwrite("~n Recieved input from server to mine, starting mining"),
                      start_mining(Zeros,IP_final)
        end.


start() ->
  {ok, IP} = io:read("~n Enter masters IP address with which you want to connect: "),
  IP_int = string:join(["master", IP], "@"),
  IP_final=list_to_atom(IP_int),
  spawn(fun() -> connect_to_master(IP_final) end).