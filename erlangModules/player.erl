%% @author David
%% @doc @todo Add description to player.


-module(player).

%% ====================================================================
%% API functions
%% ====================================================================
%spawn will later be overloaded with default value versions
-export([spawn/11,spawn/10]).

%turn into paramter list
%record for player
spawn(Deck,KeyListner,HandBinds, StartHandSize,%for the deck
	MoveBinds,Board,Pos,Side,Hp,ETickTime,MoveTickTime)->%for the movement
	CurrentPos=playerMover:start(Board, Pos, KeyListner, Side, Hp, MoveBinds,[{maxSpeed,MoveTickTime}]),
	playerCaster:start(Deck,KeyListner,HandBinds,StartHandSize,CurrentPos,Side,Board,ETickTime).
	
spawn(Deck,KeyListner,HandBinds, StartHandSize,%for the deck
	MoveBinds,Board,Pos,Side,Hp,ETickTime)->%for the movement
	CurrentPos=playerMover:start(Board, Pos, KeyListner, Side, Hp, MoveBinds,[]),
	playerCaster:start(Deck,KeyListner,HandBinds,StartHandSize,CurrentPos,Side,Board,ETickTime).
%% ====================================================================
%% Internal functions
%% ====================================================================


