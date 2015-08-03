%% @author David
%% @doc @todo Add description to cost.


-module(cost).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/1,newWallet/2,pay/2,toXML/1,addCrystal/2]).

new({_,Gems,Cost}) when erlang:is_integer(Cost)->
	case atomHolder:count(Gems) of 
		0 -> [{undef,Cost}];
		N when is_integer(N)-> N2=trunc(Cost/N),makeCost(N2,Gems,[])
	end.
%the time between things happening
%in the game 
newWallet(Player,TickTime)->
	Pid=spawn_link(fun()->constructor(Player,TickTime) end),
	playerData:add(Player,{wallet,Pid}),
	Pid.

addCrystal(Type,Wallet) when erlang:is_pid(Wallet)->
	Wallet ! {crystal, Type};
addCrystal(Type,Player) when erlang:is_reference(Player)->
	W=getWallet(Player),
	addCrystal(Type, W).
pay(Cost,Player) when erlang:is_reference(Player)->
	W=getWallet(Player),
	pay(Cost,W);
pay(Cost,Wallet) when erlang:is_pid(Wallet)->
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
makeCost(N,Gems,List)->
	case atomHolder:get(Gems) of
		{Atom,Rest}->makeCost(N,Rest,[{Atom,N}|List]);
		_->List
	end.
getWallet(Player)->
	Data=playerData:get(Player),
	[{wallet,Pid}]=option:get(Data,[{wallet,required}]),
	Pid.

constructor(Player,TickTime)-> 
	utils:pacemaker(cash, TickTime),
	UI=playerUI:request(Player),
	A=atomHolder:create(),
	loop(0,A,UI).

loop(N,AtHolder,UI)->
	show(N,AtHolder,UI),
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
show(N,AtHolder,UI)->
	playerUI:show(UI,1,{N,{100,100,0}}),
	playerUI:show(UI,2,{atomHolder:count(AtHolder,red),{200,0,0}}),
	playerUI:show(UI,3,{atomHolder:count(AtHolder,green),{0,200,0}}),
	playerUI:show(UI,4,{atomHolder:count(AtHolder,blue),{0,0,200}}),
	playerUI:show(UI,5,{atomHolder:count(AtHolder,white),{200,200,200}}).
