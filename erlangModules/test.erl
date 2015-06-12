%% @author David
%% @doc @todo Add description to test.


-module(test).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0]).

start()->
	playCardsTest().
write(Data)->
	{ok,FP}=file:open("db.xml", [write,raw]),
	file:write(FP, Data).
genXML()->
	Root=lXML:to(cards),
	Root2=for(Root,100),
	R3=lXML:serialize(Root2),
	R3.
for(Root,0)->Root;
for(Root,N)->
	A=card:new(),
	B=card:toXML(A),
	R2=lXML:insert(Root, B),
	for(R2,N-1).

momentumTest()->
	{Board,KeyListner}=board:start(10),
	MoveBinds=[{up,$W},{down,$S},{right,$D},{left,$A}],
	MoveBinds2=[{up,$I},{down,$K},{right,$L},{left,$J}],
	StartHandSize=4,
	Deck=deck:new(),
	Deck2=deck:new(),
	Side=red,
	Side2=blue,
	Hp=100,
	Pos={3,3},
	Pos2={7,7},
	HandBinds=[{{cast,1},$1},{{cast,2},$2},{{cast,3},$3},{{cast,4},$4}],
	HandBinds2=[{{cast,1},$7},{{cast,2},$8},{{cast,3},$9},{{cast,4},$0}],
	ETime=1,
	MaxMs=1,
	player:spawn(Deck, KeyListner, HandBinds, StartHandSize, MoveBinds, Board, Pos, Side, Hp,ETime,MaxMs),
	player:spawn(Deck2, KeyListner, HandBinds2, StartHandSize, MoveBinds2, Board, Pos2, Side2,Hp,ETime,MaxMs).

playCardsTest()->
	{Board,KeyListner}=board:start(10),
	MoveBinds=[{up,$W},{down,$S},{right,$D},{left,$A}],
	MoveBinds2=[{up,$I},{down,$K},{right,$L},{left,$J}],
	StartHandSize=4,
	Deck=deck:new(),
	Deck2=deck:new(),
	Side=red,
	Side2=blue,
	Hp=100,
	Pos={3,3},
	Pos2={7,7},
	HandBinds=[{{cast,1},$1},{{cast,2},$2},{{cast,3},$3},{{cast,4},$4}],
	HandBinds2=[{{cast,1},$7},{{cast,2},$8},{{cast,3},$9},{{cast,4},$0}],
	ETime=1,
	player:spawn(Deck, KeyListner, HandBinds, StartHandSize, MoveBinds, Board, Pos, Side, Hp,ETime),
	player:spawn(Deck2, KeyListner, HandBinds2, StartHandSize, MoveBinds2, Board, Pos2, Side2,Hp,ETime).

moveAndColideTest()->
	{Board,KeyListner}=board:start(10),
	Pos={5,1},
	Side=red,
	Size=1,
	KeyBinds=[{up,$W},{down,$S},{right,$D},{left,$A}],
	playerMover:start(Board, Pos, KeyListner, Side, Size, KeyBinds),
	Pos2={1,5},
	Side2=green,
	KeyBinds2=[{up,$I},{down,$K},{right,$L},{left,$J}],
	playerMover:start(Board, Pos2, KeyListner, Side2, Size, KeyBinds2).

side_applyToAll_test()->
	{Board,_KeyListner}=board:start(10),
	permanent:create({5,5}, Board, 100, red),
	permanent:create({2,2}, Board, 100, red),
	Func=fun(Pos)->
			io:write({Pos})
	end,
	side:applyToAll(Func, red).
%% ====================================================================
%% Internal functions
%% ====================================================================


