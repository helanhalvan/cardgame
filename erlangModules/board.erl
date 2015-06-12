%% @author David
%% @doc @todo Add description to board.


-module(board).
-export([start/1,new/1,spawn/3,move/3,kill/2,scan/4,scanAndUpdate/5]).
%-compile(export_all).
%== public interface
%constructor
new(Size)->start(Size).
start(Size)->
	A=emptyBoard(Size),
	{UI,Event}=matrixUI:start({Size,Size}),
	C=spawn_link(fun()-> loop(A, Size, UI) end),
	{C,Event}.
%normal mesages

%clears a Pos
kill(Board,Pos)->
	C=makeCaller(),
	Board ! {kill, Pos, C,[]},
	waitForAck(C).
%moves 
%whats in Src
%to Target
%returns one of: 
% ok
% nothingToMove
% hitSomething
% outOfBounds
move(Board,Src,Target)->
	C=makeCaller(),
	Board ! {move, Target, C, [Src]},
	waitForAck(C).
%creates 
%a thing
%on target
spawn(Board,Target,Thing)->  
	C=makeCaller(),
	Board ! {spawn, Target,C,[Thing]},
	waitForAck(C).
%applies Funk(PosList,Acc), to 
%the contents of all positions 
%of PosList in order
%returns the resulting Acc
scan(Board,PosList,Funk,Acc)->
	C=makeCaller(),
	Board ! {apply,PosList,C,Funk,Acc},
	waitForAck(C).
%same as scan, but 
%uses the finnal Acc as param for
%ApplyFunk, that is applied for each position
%updating that position
%ApplyFunk(Pos,Acc)=>{Dude,Acc}
scanAndUpdate(Board, PosList, ScanFunk, Acc, ApplyFunk)->
	C=makeCaller(),
	Board ! {applyNupdate,PosList,C,ScanFunk,Acc,ApplyFunk},
	waitForAck(C).
%===================================================================
%msg passing utility funks

%makes Caller object so board can reply
makeCaller()->
	utils:makeCaller().
%waits for reply, returns the reply
waitForAck(Caller)->
	utils:waitForAck(Caller).
%sends ack
ack(Caller)->
	utils:ack(Caller).
%sends error, Msg is the error msg
senderror(Caller,Msg)->
	utils:sendMsg(Caller, Msg).

%process loop
loop(Board, Size, UI)->
	receive
		%handles out of board msgs
		{_,{X,Y},Caller,_} when X>Size ; X<1 ; Y>Size ; Y<1  -> 
			senderror(Caller, outOfBounds);
		
		{move,Target, Caller, [Src]} -> 
			case get(Src,Board) of 
				nil -> senderror(Caller, nothingToMove);
				Dude -> case get(Target,Board) of 
							nil ->set(Target,Board,Dude,UI),
									clear(Src,Board,UI),
									ack(Caller);
							_Something->senderror(Caller, hitSomething)
						end
			end;
		
		{spawn,Target,Caller, [Something]}=A-> 
			case get(Target,Board) of
				nil ->set(Target, Board, Something,UI),
					  ack(Caller);
				_ -> senderror(Caller,{A, spawnSlotFull})
			end;
		
		{kill,Pos, Caller,_} -> 
			clear(Pos,Board,UI), 
			ack(Caller);
		{apply,PosList,C,Funk,Acc0} ->
			Acc1=scanEach(PosList,Funk,Acc0,Board),
			senderror(C,Acc1);
		{applyNupdate,PosList,C,Funk,Acc,Funk2} ->
			Acc1=scanEach(PosList,Funk,Acc,Board),
			applyToEach(PosList,Funk2,Acc1,Board,UI),
			ack(C)
	end,
	loop(Board,Size, UI).
%==utility functions for loop
scanEach(PosList,Funk,Acc0,Board)->
	A=fun(Pos,Acc)->
		D=get(Pos,Board),
		Funk(D,Acc)
		  end,
	lists:foldl(A, Acc0, PosList).
applyToEach(PosList,Funk,Acc0,Board,UI)->
	A=fun(Pos,Acc)->
			D=get(Pos,Board),
			{Result,Acc1}=Funk(D,Acc),
			set(Pos,Board,Result,UI),
			Acc1 end,
	lists:foldl(A, Acc0, PosList).
set({_,_}=A,Board, {Team,Size}=Dude,UI)->
	Cell=find(A,Board),
	C=side:team_to_color(Team),
	matrixUI:setSquare(A,{Size,C},UI),
	memCell:set(Cell, Dude);

set({_,_}=A,Board, nil,UI)->
	Cell=find(A,Board),
	matrixUI:setSquare(A,{0,{0,0,0}},UI),
	memCell:set(Cell, nil).

get(Pos,Board) ->
	A=find(Pos,Board),
	memCell:get(A).

find({X,Y}, Board)->
	Line=element(X, Board),
	element(Y,Line).

clear({_,_}=A,Board,UI)->
	B=find(A,Board),
	case memCell:get(B) of
		nil -> ok;
		_ -> set(A,Board,nil,UI)
	end.

%=== board generator
emptyBoard(Size)->
	list_to_tuple(makeBoard(0,Size)).

makeBoard(S,S)->[];
makeBoard(N,S)->[list_to_tuple(makeRow(S))|makeBoard(N+1,S)].

makeRow(0)->[];
makeRow(N)->[empty()|makeRow(N-1)].

empty() -> memCell:start().
