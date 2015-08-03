%% @author David
%% @doc @todo Add description to side.


-module(side).

%% ====================================================================
%% API functions
%% ====================================================================
-export([register/2,team_to_color/1]).
-compile(export_all).

register(Ref,{_,_,_}=Color) when is_reference(Ref)->
	Pid=getColorList(),
	Pid ! {new, Ref,Side}.

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

getColorList()->
	utils:getPid(colorList, fun()->loop([])end).
