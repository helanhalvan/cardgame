%% @author David
%% @doc @todo Add description to opthandler.


-module(option).

%% ====================================================================
%% API functions
%% ====================================================================
-export([get/2,test/0]).
%returns the options from opts
%pattern [{key,BEHAVIOR()}]
%BEHAVIOR() = required | optional | {default,DefaultValue}
get(Opts,Extractpattern)->
	get(Opts,Extractpattern,[]).
test()->
	error=get([{aasd,asdasd}],[{a,required}]),
	[{a,abc},{b,def}]=get([{b,def},{a,abc},{derp,derp}],[{a,optional},{b,{default,derp}}]),
	ok.
%% ====================================================================
%% Internal functions
%% ====================================================================

get(_Opts,[],Res)->
 	lists:reverse(Res);
get(Opts,[{Key,required}|T],Res)->
	case lists:keyfind(Key, 1, Opts) of
		false -> error;
		New -> get(Opts,T,[New|Res])
	end;

get(Opts,[{Key,optional}|T],Res)->
	case lists:keyfind(Key, 1, Opts) of
		false -> get(Opts,T,Res);
		New -> get(Opts,T,[New|Res]) 
	end;
get(Opts,[{Key,{default,Value}}|T],Res)->
	case lists:keyfind(Key, 1, Opts) of
		false -> get(Opts,T,[{Key,Value}|Res]);
		New -> get(Opts,T,[New|Res]) 
	end.