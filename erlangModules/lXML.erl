%% @author David
%% @doc @todo Add description to lXML.


-module(lXML).

%% ====================================================================
%% API functions
%% ====================================================================
-export([to/1,insert/2,serialize/1,children/1]).

to(Name)->
	{lXML,Name,[]}.
insert({lXML,Name,List},Append) when erlang:is_list(Append)->
	{lXML, Name,List++Append};
insert({lXML,Name,List},Int) when erlang:is_integer(Int)->
	S=erlang:integer_to_list(Int),
	{lXML,Name,[S|List]};
insert({lXML,Name,List},{lXML,_,_}=A)->
	{lXML,Name,[A|List]};
insert({lXML,Name,List},Atom) when erlang:is_atom(Atom)->
	S=erlang:atom_to_list(Atom),
	{lXML,Name,[S|List]}.

serialize({lXML,Name,[H|T]})->
	head(Name)++serialize(H)++list(T)++tail(Name);
serialize(String) when is_list(String)->
	String.

children({lXML,_,Children})->
	Children.
%% ====================================================================
%% Internal functions
%% ====================================================================

head(Name) when is_list(Name)->
	[$<]++Name++[$>];
head(Name) when is_atom(Name)->
	Name2=erlang:atom_to_list(Name),
	head(Name2).

tail(Name) when is_list(Name)->
	[$<,$/]++Name++[$>];
tail(Name) when is_atom(Name)->
	Name2=erlang:atom_to_list(Name),
	tail(Name2).

list([H|T])->
	serialize(H)++list(T);
list([])->" ".

