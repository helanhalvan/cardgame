%% @author David
%% @doc @todo Add description to playerData.


-module(playerData).

%% ====================================================================
%% API functions
%% ====================================================================
-export([get/1,register/1,unregister/1,add/2]).

get(Name) when erlang:is_reference(Name)->
	Mpid=getMaster(),
	Caller=utils:makeCaller(),
	Mpid ! {get,Name,Caller},
	utils:waitForAck(Caller).
register(Options)->
	[{name,Name}]=option:get(Options,[{name,required}]),
	Mpid=getMaster(),
	Mpid ! {create, Name, Options}.
unregister(Name)->
	Mpid=getMaster(),
	Mpid ! {kill, Name}.
add(Name, Thing) when erlang:is_tuple(Thing)->
	Mpid=getMaster(),
	Mpid ! {add, Name, Thing}.
%% ====================================================================
%% Internal functions
%% ====================================================================
getMaster()->
	utils:getPid(pDataMaster, fun()->master([]) end).

master(List)->
	NList=(
	receive
		{kill,Name}	-> lists:keydelete(Name, 1, List);
		{create, Name, Options} -> [{Name,Options}|List];
		{get,Name,Caller}->{Name,Data}=lists:keyfind(Name, 1, List),utils:sendMsg(Caller, Data),List;
		{add, Name, Thing} -> 
							 case lists:keytake(Name, 1, List) of
								 {value, {Name,Opts}, TList} -> [{Name,lists:flatten([Thing|Opts])}|TList];
								 false -> List
							 end
	end),
	master(NList).