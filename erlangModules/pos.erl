%% @author David
%% @doc @todo Add description to pos.


-module(pos).

%% ====================================================================
%% API functions
%% ====================================================================
-export([is/1,new/2,up/2,down/2,right/2,left/2,scatterFunk/0,dir/3]).

is({_,_})->
	true;
is(_)->
  	false.
new(X,Y)->
	{pos,X,Y}.
%TODO 
dir({X,Y},Z,Dir)->
	na.
%returns the square
%Z squares in the given
%direction
left({X,Y},Z)->
	{X,Y-Z}.
right({X,Y},Z)-> 
	{X,Y+Z}.
up({X,Y},Z)->
	{X-Z,Y}.
down({X,Y},Z)->
	{X+Z,Y}.
%returns a closure
%that takes a pos as parameter
%and returns a pos that's 
%close to the original
%in the form {Fun,Metadata}
scatterFunk()->
	X=dice:getRand(5),
	Dir=dice:getRand(4),
	Fun=case Dir of
		1->fun(Pos)->up(Pos,X) end;
		2->fun(Pos)->down(Pos,X)end;
		3->fun(Pos)->right(Pos,X)end;
		4->fun(Pos)->left(Pos,X)end
	end,
	Meta=case Dir of
		1->{up,X};
		2->{down,X};
		3->{right,X};
		4->{left,X}
	end,
	{Fun,Meta}.
%% ====================================================================
%% Internal functions
%% ====================================================================


