%% @author David
%% @doc @todo Add description to playerCaster.


-module(playerCaster).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1]).
%handles cards for a player
start(Options)->
	io:write(casterStarting),
	[{eTick,TickTime}]=option:get(Options,[{eTick,{default,1}}]),
	[{startHand,StartHand}]=option:get(Options,[{startHand,{default,5}}]),
	[{deck,Deck}]=option:get(Options,[{deck,{default,deck:new()}}]),
	io:write(caster20),
	[{posSrc,PosSrc}]=option:get(Options,[{posSrc,required}]),
	[{resHolder,Holder}]=option:get(Options,[{resHolder,required}]),
	[{name,Player}]=option:get(Options,[{name,required}]),
	io:write(caster40),
	{board,Board}=keyValueStore:get(Holder,board),
	io:write(caster45),
	{Rest,Hand}=draw(Deck,{[],0},StartHand),
	UI=playerUI:request(Player),
	%{UI,_}=matrixUI:start({10,2}),
	Wallet=cost:newWallet(Player,TickTime),
	io:write(caster50),
	Pid=spawn_link(fun()->loop(Rest,Hand,{Player,Board,PosSrc},Wallet,UI)end),
	io:write(caster100),
	{ok,Pid}.

loop(Deck,{_,Count}=Hand,{Player,Board,Mover}=A,Payer,UI)->
		pushHand(Hand,UI),
		receive 
		draw -> {{_,Count}=NewHand,NewDeck}=draw(Deck,Hand,1),
				loop(NewDeck,NewHand,A,Payer,UI);
		{cast,N} when N>Count ->loop(Deck,Hand,A,Payer,UI);
		{cast,N}->Card=cardNr(Hand,N),
				  SrcPos=playerMover:askForPos(Mover),
				  case card:cast(Card, Board, SrcPos, Player) of 
					  ok->NewHand=removeCard(Hand,N),loop(Deck,NewHand,A,Payer,UI);
					  failed->loop(Deck,Hand,A,Payer,UI)
				  end;
		_->loop(Deck,Hand,A,Payer,UI)
	end.

pushHand({_,0},_)->
	ok;
pushHand({_,Count}=Hand,UI)->
	playerUI:show(UI,Count,{a,{0,128,0}}),
	%matrixUI:setSquare({1,2},{Count-1,{0,128,0}} ,UI),
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
	playerUI:show(UI,N,{nothing,{0,0,0}} );
pushCard(Card,N,UI) when erlang:is_integer(N)->
	Text=card:getText(Card),
	playerUI:show(UI,N,{Text,{0,128,0}}).

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


