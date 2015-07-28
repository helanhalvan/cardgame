%% @author David
%% @doc @todo Add description to resmon.


-module(keyValueStore).
%local resourse monitor
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0,get/2,add/3,list/1]).

get(Monitor,Name)->
	Caller=utils:makeCaller(),
	Monitor ! {req, Caller, Name},
	utils:waitForAck(Caller).
add(Monitor,Name,Id)->
	Monitor ! {new, Name, Id}.
list(Monitor)->
	Monitor ! list.
start()->
	Pid=spawn_link(fun()->loop([]) end),
	{ok, Pid}.
%% ====================================================================
%% Internal functions
%% ====================================================================

loop(Things)->
	NewThings=(receive
		{req, Caller, Name} -> findAndReturn(Caller,Things, Name), Things;
		{new, Name, Pid} -> add(Things, {Name,Pid});
		list -> io:write(Things), Things
	end),
	loop(NewThings).

findAndReturn(Caller, List, Name)->
	Msg=lists:keyfind(Name, 1, List),
	utils:sendMsg(Caller, Msg).
add(List, A)->
	L2=lists:delete(A, List),
	[A|L2].
