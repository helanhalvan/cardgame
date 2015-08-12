%% @author David
%% @doc @todo Add description to atomHolder.

-module(atomHolder).

%% ====================================================================
%% API functions
%% ====================================================================
-export([create/0,add/2,count/2,remove/2,count/1,get/1]).

create()->[].

add(Holder,Atom) when is_atom(Atom)->
	case lists:keysearch(Atom, 1, Holder) of
		{value,{Atom,N}}->H2=lists:delete({Atom,N}, Holder),
				  [{Atom,N+1}|H2];
		false->[{Atom,1}|Holder]
	end.
%removes if exists, otherwise returns error
remove(Holder,Atom) when is_atom(Atom)->
	case lists:keysearch(Atom, 1, Holder) of 
		{value,{Atom,1}}->H2=lists:delete({Atom,1}, Holder),
				  {ok,H2};
		{value,{Atom,N}}->H2=lists:delete({Atom,N}, Holder),
				  {ok,[{Atom,N-1}|H2]};
		false -> error
	end.
%counts the occurances of an atom
count(Holder,Atom) when is_atom(Atom)->
	case lists:keysearch(Atom, 1, Holder) of
		{value,{Atom,N}}-> N;
		false-> 0
	end.
%counts the number of atoms in the holder
count(Holder)->
	lists:foldl(fun({_,Y},X)-> X+Y end, 0, Holder).

%returns a atom and a holder without that atom {Atom,NewHolder}
get([])->
	error;
get([{Atom,1}|T])->
	{Atom,T};
get([{Atom,N}|T])->
	{Atom,[{Atom,N-1}|T]}.
%% ====================================================================
%% Internal functions
%% ====================================================================




