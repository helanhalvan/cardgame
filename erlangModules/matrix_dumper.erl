%% @author David
%% @doc @todo Add description to boardUI.


-module(matrix_dumper).
%%DEPRICATED!!!! FOR TESTING ONLY, USES CONSOLE
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/2,newFrame/1]).

start(Matrix, Size)->
	Limit=(Size+1),
	spawn_link(fun()-> loop(Matrix, Limit) end).

newFrame(UI)->
	UI ! frame.
%% ====================================================================
%% Internal functions
%% ====================================================================

loop(Board, Size)->
	receive
		frame -> pushFrame(Board,Size,1)
	end,
	loop(Board,Size).
pushFrame(_,S,S)->
	ok,
	io:write('===========================================================');
pushFrame(Board,Size,Count)->
	pushRow(Board,Size,1,Count),
	pushFrame(Board, Size,Count+1).
pushRow(_,S,S,_)->
	io:nl();
pushRow(Board,Size,Count,Y)->
	A=element(Y,Board),
	B=element(Count,A),
	io:write({memCell:get(B)}),
	pushRow(Board,Size,Count+1,Y).