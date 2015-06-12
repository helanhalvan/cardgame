%% @author David
%% @doc @todo Add description to playerCaster.


-module(playerCaster).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/8]).
%handles cards for a player
start(Deck,KeyListner,KeyBinds,StartHand,Mover,Side,Board,TickTime)->
	{Rest,Hand}=draw(Deck,{[],0},StartHand),
	{UI,_}=matrixUI:start({10,2}),
	Wallet=cost:newWallet(TickTime),
	Pid=spawn_link(fun()->loop(Rest,Hand,{Side,Board,Mover},Wallet,UI)end),
	Callback=utils:makeKeyCallback(Pid, KeyBinds),
	keyListner:register(Callback, KeyListner).

loop(Deck,{_,Count}=Hand,{Side,Board,Mover}=A,Payer,UI)->
		pushHand(Hand,UI),
		receive 
		draw -> {{_,Count}=NewHand,NewDeck}=draw(Deck,Hand,1),
				loop(NewDeck,NewHand,A,Payer,UI);
		{cast,N} when N>Count ->loop(Deck,Hand,A,Payer,UI);
		{cast,N}->Card=cardNr(Hand,N),
				  SrcPos=playerMover:askForPos(Mover),
				  case card:cast(Card, Board, SrcPos, Payer, Side) of 
					  ok->NewHand=removeCard(Hand,N),loop(Deck,NewHand,A,Payer,UI);
					  failed->loop(Deck,Hand,A,Payer,UI)
				  end;
		Strange->io:write({playerCaster_Got,Strange})
	end.

pushHand({_,0},_)->
	ok;
pushHand({_,Count}=Hand,UI)->
	matrixUI:setSquare({1,2},{Count-1,{0,128,0}} ,UI),
	pushHand(Hand,UI,1);
pushHand(11,_)->
	ok;
pushHand(N,UI)->
	pushCard(nil,N, UI),
	pushHand(N+1,UI).

pushHand({_,Count}=_Hand,UI,Count)->
	pushHand(Count,UI);
pushHand(Hand,UI,N) when N>0->
	Card=cardNr(Hand,N),
	pushCard(Card,N,UI),
	pushHand(Hand,UI,N+1).


pushCard(nil,N,UI) when erlang:is_integer(N)->
	matrixUI:setSquare({N,1},{nothing,{0,0,0}} , UI);
pushCard(Card,N,UI) when erlang:is_integer(N)->
	Text=card:getText(Card),
	matrixUI:setSquare({N,1},{Text,{0,128,0}} , UI).

draw(Deck,Hand,-1)->
	{Deck,Hand};
draw(Deck,{Hand,Count},N)->
	{Card,Rest}=Deck(),
	draw(Rest,{[Card|Hand],Count+1},N-1).

cardNr({_,Count},N) when N>Count ->
	nil;
cardNr({List,_},N)->
	cardNr(List,N);
cardNr([H|_],1)->
	H;
cardNr([_|T],N)->
	cardNr(T,N-1).

removeCard({List,Count},N) when N>Count ->
	{List,Count};
removeCard({List,Count},N)->
	{removeCard(List,N),Count-1};
removeCard([_|T],1)->
	T;
removeCard([H|T],N)->
	[H|removeCard(T,N-1)].
%% ====================================================================
%% Internal functions
%% ====================================================================


