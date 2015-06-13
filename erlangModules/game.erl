%% @author David
%% @doc @todo Add description to game.


-module(game).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1,start/0]).
start()->na.
start(Options)->
	case opts(Options) of
		fail -> error;
		{BoardOpts,PlayerOpts}->
			Sup=self(),
			Board={board, fun()->board:start(BoardOpts) end,temporary,brutal_kill,supervisor,dynamic},
			supervisor:start_child(Sup,Board)
	end.
%% ====================================================================
%% Internal functions
%% ====================================================================

opts(Options)->
 {BoardOpts,PlayerOpts}.
