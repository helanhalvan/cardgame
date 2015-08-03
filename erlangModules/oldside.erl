%% @author David
%% @doc @todo Add description to side.


-module(oldside).

%% ====================================================================
%% API functions
%% ====================================================================
-export([register/2,applyToAll/2,remove/2,team_to_color/1,getPlayer/1]).
-compile(export_all).
%the given Pos
%is now on the given Side
%can't handle duplicate calls
%if the Pos is a Ref, it's a player
register(Ref,Side) when is_reference(Ref),erlang:is_reference(Side)->
	Pid=getPlayerHandler(),
	Pid ! {new, Ref,Side};
register(Pos,Side) when erlang:is_reference(Side)->
	Pid=getPid(Side),
	Pid ! {new, Pos}.
%applies Func
%to all Pos
%on the given Side
applyToAll(Func,Side)->
	Pid=getPid(Side),
	Pid ! {applyToAll,Func}.
%the given Pos is
%no longer on the given side
remove(Ref,Side) when is_reference(Ref)->
	Pid=getPlayerHandler(),
	Pid ! {remove,Ref,Side};
remove(Pos,Side)->
	Pid=getPid(Side),
	Pid ! {remove, Pos}.
getPlayer(Side)->
	Pid=getPlayerHandler(),
	Pid ! {get, Side, 0}.
%team to color cases
team_to_color(red)->
	{255,0,0};
team_to_color(green)->
	{0,255,0};
team_to_color(blue)->
	{0,0,255};
team_to_color({Color,_})->
	team_to_color(Color);
team_to_color({_,_,_}=A)->
	A;
team_to_color(_Term)->
	{100,100,100}.
%% ====================================================================
%% Internal functions
%% ====================================================================

%non players
loop(List)->
	receive
		{new, Pos} -> loop([Pos|List]);
		{applyToAll,Func}->NewList=moveAll(Func,List,[]),loop(NewList);
		{remove, Pos}-> A=lists:delete(Pos, List),loop(A);
		dump->io:write(List),loop(List)
	end.
getPid(SideAtom)->
	utils:getPid(SideAtom, fun()->loop([])end).
moveAll(_,[],List)->List;
moveAll(Func,[H|T],List)->
	Res=Func(H),
	moveAll(Func,T,[Res|List]).
%players
getPlayerHandler()->
	utils:getPid(playerHandler, fun()->playerLoop([])end).

playerLoop(List)->
	receive
		{new, Ref,Side}->NewList=add(List,Side,Ref),playerLoop(NewList);
		{remove, Ref,Side}->NewList=remove(List,Side,Ref),
							case haveWinner(NewList) of
								true->ok;
								false ->playerLoop(NewList) 
							end;
		{get, Side,N}->get(List,N,Side);
		dump->io:write(List),playerLoop(List)
	end.

get([{Side,Players}|_T],Number,Side)->
	get(Players,Number);
get([_|T],N,S)->
	get(T,N,S);
get([],_,_)->
	error.

get([H|_T],0)->
	H;
get([_,T],N)->
	get(T,N-1).
%[{team1,[member1]},{team2,[member1]}]
add(List,Side,Ref)->
	add(List,Side,Ref,[]).
add([],Side,Ref,Checked)->
	[{Side,[Ref]}|Checked];
add([{Side,Players}|T],Side,Ref,Checked)->
	[[{Side,[Ref|Players]}|T]|Checked];
add([H|T],Side,Ref,Checked)->
	add(T,Side,Ref,[H|Checked]).
remove(List,Side,Ref)->
	remove(List,Side,Ref,[]).

remove([],_Side,_Ref,Checked)->
	Checked;
remove([{Side,[Ref]},T1],Side,Ref,Checked)->
	[T1|Checked];
%only required for 2 players on same team
%remove([{Side,_List},T],Side,Ref,Checked)->
%	na;
remove([H,T],Side,Ref,Checked)->
	remove(T,Side,Ref,[H|Checked]).

haveWinner([{Side,_}])->
	io:write({Side,have_won_the_game}),
	true;
haveWinner(_List)->
	false.