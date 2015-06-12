%% @author David
%% @doc @todo Add description to card.


-module(card).

%% ====================================================================
%% API functions
%% ====================================================================
-export([cast/5,new/0,getText/1,toXML/1]).
new()->
	{E,Meta}=effect:new(),
	Cost=cost:new(Meta),
	{card,E,Cost,Meta}.

cast({card,E,Cost,_},Board,SrcPos,Wallet,Side)->
	case cost:pay(Cost, Wallet) of
		ok->effect:apply(Board, E, SrcPos, Side);
		_->failed
	end.
%returns the cards text
getText({card,_,_,Meta})->
	Meta.
toXML({card,_,Cost,{Meta,_,_}})->
	A=lXML:to(card),
	B=lXML:insert(A, cost:toXML(Cost)),
	lXML:insert(B, Meta).

%% ====================================================================
%% Internal functions
%% ====================================================================
%%{card,Effect,Cost,Metadata}

