%% @author David
%% @doc @todo Add description to pixel.


-module(memCell).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0,get/1,set/2]).

start()->
spawn_link(fun()->loop(nil)end).

loop(Something)->
	receive
	{set, NewThing} -> loop(NewThing);
	{get, ToMe, Ref} -> ToMe ! {Ref, Something},loop(Something)
end.

get(MemCell)->
	A=self(),
	B=make_ref(),
	MemCell ! {get, A, B},
	receive
		{B,Something} -> Something
	end.
set(MemCell, NewThing)->
	MemCell ! {set, NewThing}.
