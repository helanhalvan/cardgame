%% @author David
%% @doc @todo Add description to resmon.


-module(keyValueStore).
%local resourse monitor
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0,get/2,add/3]).

get(Monitor,Name)->
	Caller=utils:makeCaller(),
	Monitor ! {req, Caller, Name},
	utils:waitForAck(Caller).
add(Monitor,Name,Pid)->
	Monitor ! {new, Name, Pid}.
start()->
	spawn_link(fun()->loop([]) end).
%% ====================================================================
%% Internal functions
%% ====================================================================

loop(Things)->
	NewThings=(receive
		{req, Caller, Name} -> findAndReturn(Caller,Things, Name), Things;
		{new, Name, Pid} -> add(Things, {Name,Pid})
	end),
	loop(NewThings).

findAndReturn(Caller, List, Name)->
	Msg=lists:keyfind(Name, 1, List),
	utils:sendMsg(Caller, Msg).
add(List, A)->
	L2=lists:delete(A, List),
	[A|L2].
