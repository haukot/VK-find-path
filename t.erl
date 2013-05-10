-module(t).
-export([init/0, test_my_fr/0]).

init() ->
	inets:start(),
	ssl:start().

make_request(Method, Params) ->
	Base_uri = "https://api.vk.com/method/",
	Request_uri = Base_uri ++ Method ++ "?" ++ Params,
	Response = httpc:request(Request_uri),
	{ok, {_, _, Html_response}} = Response,
	Html_response.

get_friends_full_info(Id) ->
	Method = "friends.get",
	Params = "uid=" ++ integer_to_list(Id) ++ "&fields=domain",
	_Html_response = make_request(Method, Params).

get_friends_id(Id) ->
	Method = "friends.get",
	Params = "uid=" ++ integer_to_list(Id),
	_Html_response = make_request(Method, Params),
	f:write(_Html_response, integer_to_list(Id) ++ ".txt"),
	_Html_response.

get_fr_by_id_list(Id_list) ->
	[spawn( fun()->get_friends_id(Temp_id) end )||Temp_id <- Id_list].

test_my_fr() ->
	{_,Time_begin} = erlang:localtime(),
	Id = 150504,
	My_fr = get_friends_id(Id),
	{struct, Parsed_json} = mochijson2:decode(list_to_binary(My_fr)),
	Response = lists:nth(1, Parsed_json),
	{_, Fr_list} = Response,
	get_fr_by_id_list(Fr_list),
	{_,Time_end} = erlang:localtime(),
	{res, {'time begin', Time_begin}, {'time end', Time_end}}.


%https://api.vk.com/method/friends.get?uid=55827129&count=20&fields=domain