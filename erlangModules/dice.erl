%% @author David
%% @doc @todo Add description to dice.


-module(dice).

%% ====================================================================
%% API functions
%% ====================================================================
-export([getRand/1]).

start()->
utils:getPid(dice,fun()->startup() end).

startup()->
	random:seed(erlang:now()),
	loop().

loop()->
receive
	{max, N, Pid} -> Pid ! {rand, random:uniform(N)}
end,
loop().

getRand(MaxValue)->
	Dice=start(),
  	Dice ! {max, MaxValue, self()},
	receive 
		{rand, Nr} -> Nr
	end.

%% ====================================================================
%% Internal functions
%% ====================================================================


