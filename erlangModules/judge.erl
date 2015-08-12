%% @author David
%% @doc @todo Add description to judge.


-module(judge).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0,newPlayer/2,lost/2,done/2]).

start()->spawn_link(fun()->loopAdd([])end).

newPlayer(Judge,Player)->
	Judge ! {new, Player}.
done(Judge,ResHandler)->
	Judge ! {done,ResHandler}.
lost(Judge,Player)->
	Judge ! {lost, Player}.

%% ====================================================================
%% Internal functions
%% ====================================================================

loopAdd(Players)->
	receive
		{new, Player} ->loopAdd([Player|Players]);
		{done,ResHandler} -> loop(Players,ResHandler)
	end.
loop([Winner],ResHandler)->
	ResHandler ! Winner,
	io:write(we_have_winner);
loop(Players,ResHandler)->
	receive
		{lost, Player} ->loop(lists:delete(Player, Players),ResHandler)
	end.