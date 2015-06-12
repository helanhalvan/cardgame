%% @author David
%% @doc @todo Add description to deck.


-module(deck).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/0]).

%creates a
%infinte deck
%of random cards
new()->
	B=fun()->draw()end,
	B.
%% ====================================================================
%% Internal functions
%% ====================================================================
draw()->
	A=card:new(),
	B=new(),
	{A,B}.

