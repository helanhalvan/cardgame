%% @author David
%% @doc @todo Add description to effect.


-module(effect).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/0,apply/4]).
%creates a new random effect
%returns {Effect,MetaData}
new()->
	GemHolder=atomHolder:create(),
	CostHolder=0,
	A=new(dice:getRand(6)+dice:getRand(6),[],[],GemHolder,CostHolder),
	fixMeta(A).
new(0,List,Meta,GemHolder,Cost)->
	A=fun(Board,SrcPos,Side) -> apply(List,Board,SrcPos,Side) end,
	{A,{Meta,GemHolder,Cost}};
new(N,List,Meta,GemHolder,CurrentCost)->
	case dice:getRand(3) of
		1-> {A,B,NewGems,NewCost}=newSpawn(GemHolder,CurrentCost);
		2-> {A,B,NewGems,NewCost}=newMove(GemHolder,CurrentCost);
		3-> {A,B,NewGems,NewCost}=newCrystal(GemHolder,CurrentCost)
	end,
	new(N-1,[A|List],[B|Meta],NewGems,NewCost).

fixMeta({A,{B,C,D}})->
	 W=list(B),
	{A,{W,C,D}}.

list(A)->
	Root=lXML:to(effects),
	list(Root,A).

list(Root,[{move,Dpos}|T])->
	A=lXML:to(effect),
	C=lXML:to(type),
	C2=lXML:insert(C, move),
	B=delta(Dpos),
	
	A2=lXML:insert(A, B),
	A3=lXML:insert(A2, C2),
	R=lXML:insert(Root, A3),
	list(R,T);

list(Root,[{spawn,S,Dpos}|T])->
	D=delta(Dpos),

	S1=lXML:to(size),
	S2=lXML:insert(S1, S),

	C=lXML:to(type),
	C2=lXML:insert(C, spawn),
	
	A=lXML:to(effect),
	A2=lXML:insert(A, C2),
	A3=lXML:insert(A2, S2),
	A4=lXML:insert(A3, D),
	
	R=lXML:insert(Root, A4),
	
	list(R,T);
list(Root,[{crystal,Type}|T])->
	
	C=lXML:to(type),
	C2=lXML:insert(C, crystal),
	
	A=lXML:to(effect),
	A2=lXML:insert(A, C2),
	A3=lXML:insert(A2, Type),
	
	R=lXML:insert(Root, A3),
	
	list(R,T);
list(R,[])->
	R.

delta({A,B})->
	C=lXML:to(dpos),
	B2=lXML:to(size),
	B3=lXML:insert(B2,B),
	A2=lXML:to(dir),
	A3=lXML:insert(A2, A),
	C2=lXML:insert(C, B3),
	lXML:insert(C2, A3).
%applies an effect 
%to a Board
%from a Pos
%for a side
apply(Board,[H|T],SrcPos,Side)->
	H(Board,SrcPos,Side),
	apply(Board,T,SrcPos,Side);
apply(_Board,[],_SrcPos,_Side)->
	ok.

%% ====================================================================
%% Internal functions
%% ====================================================================
	%adds green, might add red, $1-100 
newSpawn(Gems,N)->
	{Scatter,Meta}=pos:scatterFunk(),
	Size=dice:getRand(100),
	
	%if dude bigger then 50 + red, allways + green
	NewGems=(if 
		Size>=50 -> G=atomHolder:add(Gems, red),atomHolder:add(G, green);
		Size<50 -> atomHolder:add(Gems, green)
	end),
	%cost =+ Size
	NewCost=N+Size,
	Fun=fun(Board,SrcPos,Side)->
			Pos=Scatter(SrcPos),
			permanent:create(Pos, Board, Size, Side),
			ok
	end,
	{Fun,{spawn,Size,Meta},NewGems,NewCost}.
	%adds _ and $0
newMove(Gems,N)->
	{SFunc,Meta}=pos:scatterFunk(),
	FFun=fun(Board,_Pos,Side)->
			Func=fun(Src)->
					Target=SFunc(Src),
					case board:move(Board, Src, Target) of 
						hitSomething -> permanent:fight(Board, Src, Target);
						_ -> ok
				 	end,
				 Src
				 end,
			side:applyToAll(Func, Side),
			ok
	end,
	{FFun,{move,Meta},Gems,N+1}.
	%adds white and $25
newCrystal(Gems,N)->
	G=atomHolder:add(Gems, white),
	CType=(case dice:getRand(3) of 
			1 -> red;
			2 -> green;
			3 -> white
		   end),
	FFun=fun(_Board,_Pos,Side)->
	Player=side:getPlayers(Side), %use playerRef for finding the right wallet
	cost:addCrystal(CType,Player) %needs to be implemented
	end,
	{FFun,{crystal,CType},G,N+25}.



