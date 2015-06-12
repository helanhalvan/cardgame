%% @author David
%% @doc @todo Add description to cost.


-module(cost).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/1,newWallet/1,pay/2,toXML/1,addCrystal/2]).

new({_,Gems,Cost}) when erlang:is_integer(Cost)->
	case atomHolder:count(Gems) of 
		0 -> [{undef,Cost}];
		N when is_integer(N)-> N2=trunc(Cost/N),makeCost(N2,Gems,[])
	end.
makeCost(N,Gems,List)->
	case atomHolder:get(Gems) of
		{Atom,Rest}->makeCost(N,Rest,[{Atom,N}|List]);
		_->List
	end.
%the time between things happening
%in the game 
newWallet(TickTime)->
	spawn_link(fun()->constructor(TickTime) end).
addCrystal(Type,Player)->
	W=getWallet(Player),
	W ! {crystal, Type}.

pay(Cost,Wallet)->
	Caller=utils:makeCaller(),
	Wallet ! {pay,Cost,Caller},
	utils:waitForAck(Caller).
toXML(Cost)->
	P=lXML:to(cost),
	Acc=fun({Atom,Value},Root)->
		A=lXML:to(Atom),
		W=lXML:insert(A, Value),
		lXML:insert(Root,W)
		end,
	lists:foldl(Acc, P, Cost).
%% ====================================================================
%% Internal functions
%% ====================================================================
getWallet(Player)->
	M=getWalletManager(),
	C=utils:makeCaller(),
	M ! {get,Player,C},
	utils:waitForAck(C).
getWalletManager()->
	utils:getPid(walletManager, fun()->manager([]) end).
manager(List)->
	receive
		{add,Player,Wallet}->manager([{Player,Wallet}|List]);
		{get,Player,Caller}->W=lists:keysearch(Player, 1, List),utils:sendMsg(Caller, W),manager(List)
	end.
%TODO expand UI to Show crystals
constructor(TickTime)-> 
	utils:pacemaker(cash, TickTime),
	{UI,_}=matrixUI:start({1,1}),
	A=atomHolder:create(),
	loop(0,A,UI).

loop(N,AtHolder,UI)->
	show(N,UI),
	receive
		cash->loop(N+1,AtHolder,UI);
		{crystal,Atom}->A=atomHolder:add(AtHolder, Atom),loop(N,A,UI);
		{pay,Cost,Caller} when N>0-> utils:ack(Caller),N2=pay(Cost,AtHolder,N),loop(N2,AtHolder,UI);
		{pay,_Cost,Caller} -> utils:sendMsg(Caller, failed),loop(N,AtHolder,UI)
	end.
%costs are a list of {GemType,AltCost} pairs, where GemType is an atom and AltCost is an int
%WARNING, untested
pay([],_AtHolder,CurrentBalance)->
	CurrentBalance;
pay([{Type,Value}|T],AtHolder,CurrentBalance)->
	case atomHolder:remove(AtHolder, Type) of 
		{ok, NewHolder}->pay(T,NewHolder,CurrentBalance);
		_->pay(T,AtHolder,CurrentBalance-Value)
	end.
show(N,UI)->
	matrixUI:setSquare({1,1}, {N,{100,100,0}}, UI).