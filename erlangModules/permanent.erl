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
	field:spawn(Board, Pos, {Color,Size}).

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
	board:scanAndUpdate(Board, PosList, Funk1, Acc, Funk2).

%=internal functions

%utility
feed2_return_list(A,nothing)->
	A;
feed2_return_list(A,B)->
	[B,A].

%fight cases
%same team
fight({A,_}=B,{A,_}=C)->
	{B,C};
fight({A,_}=B,{{A,_},_}=C)->
	{B,C};
fight({{A,_},_}=B,{{A,_},_}=C)->
	{B,C};
fight({{A,_},_}=B,{A,_}=C)->
	{B,C};
%same size
fight({_,P1},{_,P1})->
	{nil,nil};
%else
fight({S1,P1},{_S2,P2}) when P1>P2->
	{{S1,P1-P2},nil};
fight({_,P1},{S2,P2}) when P1<P2->
	{nil,{S2,P2-P1}}.



