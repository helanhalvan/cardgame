%% @author David
%% @doc @todo Add description to permanent.


-module(permanent).

%% ====================================================================
%% API functions
%% ====================================================================
-export([create/4,fight/3]).
%TODO replace "side" module refs with a new module
create(Pos,Board,Size,Player) when is_pid(Board) ->
	Data=playerData:get(Player),
	[{color,Color}]=option:get(Data,[{color,required}]),
	field:spawn(Board, Pos, {Size,Color}).

%2 permanents on a given board fight
fight(Board,A,B)->
	PosList=[A,B],
	Acc=nothing,
	Funk1=fun(D,Acc0)->feed2_return_list(D,Acc0) end,
	Funk2=fun(_,IN)->
				  case IN of
					  [D1,D2] -> {C1,C2}=fight(D1,D2),{C1,C2};
					  nothing-> io:write({fight_acc_empty}),{error,nothing};
		  			  D->{D,nothing}
				  end
		  end,
	field:scanAndUpdate(Board, PosList, Funk1, Acc, Funk2).

%=internal functions

%utility
feed2_return_list(A,nothing)->
	A;
feed2_return_list(A,B)->
	[B,A].

%fight cases
%same team
fight({_,A}=B,{_,A}=C)->
	{B,C};
%same size
fight({P1,_},{P1,_})->
	{nil,nil};
%else
fight({P1,S1},{P2,_S2}) when P1>P2->
	{{P1-P2,S1},nil};
fight({P1,_},{P2,S2}) when P1<P2->
	{nil,{P2-P1,S2}};
fight(A,B)->
	io:write({A,B,no_clause_matching}),
	{nil,nil}.



