%% @author David
%% @doc @todo Add description to playerUI.


-module(playerUI).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1,request/1,show/3]).

start(Options)->
	[{pUIsize,Size}]=option:get(Options,[{pUIsize, {default,{10,10}}}]),
	[{name,Name}]=option:get(Options,[{name, required}]),
	{Pid,_}=matrixUI:start(Size),
	Pid2=erlang:spawn_link(fun()->loop(Pid,1,10,[]) end),
	playerData:add(Name,{playerUI,Pid2}),
	{Pid2,ok}.

request(Name)->
	Pid=getPid(Name),
	Caller=utils:makeCaller(),
	Pid ! {wantRow, Caller},
	Ref=utils:waitForAck(Caller),
	{Ref,Name}.
show({Ref,Name},Height,Data)->
	Pid=getPid(Name),
	Pid ! {show,Ref,Height,Data}. 
%% ====================================================================
%% Internal functions
%% ====================================================================
getPid(Name)->
	Data=playerData:get(Name),
	[{playerUI,Pid}]=option:get(Data,[{playerUI,required}]),
	Pid.
loop(UI,Aval,Max,Refs)->
	%io:write({Refs}),
	receive
		{show, Ref, Square, Data}->X=refToIndex(Refs,Ref,0),
									matrixUI:setSquare({Square,X}, Data, UI),loop(UI,Aval,Max,Refs);
		{wantRow, Caller} when Aval<Max-> Nref=erlang:make_ref(),utils:sendMsg(Caller, Nref),loop(UI,Aval+1,Max,lists:flatten([Refs,[Nref]]));
		{wantRow, Caller} -> utils:sendMsg(Caller, no_space_left),loop(UI,Aval,Max,Refs)
	end.
refToIndex([Ref|_T],Ref,Int)->
	Int+1;
refToIndex([_H|T],Ref,Int)->
	refToIndex(T,Ref,Int+1);
refToIndex([],_,_)->
	false.