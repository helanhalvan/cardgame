%% @author David
%% @doc @todo Add description to effect.


-module(effect).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/0]).
%creates a new random effect
%returns {Effect,MetaData}
new()->
	GemHolder=atomHolder:create(),
	CostHolder=0,
	A=new(dice:getRand(6)+dice:getRand(6),[],[],GemHolder,CostHolder),
	fixMeta(A).

%% ====================================================================
%% Internal functions
%% ====================================================================
%applies an effect 
%to a Board
%from a Pos
%for a Player
apply(Board,[H|T],SrcPos,Player)->
	H(Board,SrcPos,Player),
	apply(Board,T,SrcPos,Player);
apply(_Board,[],_SrcPos,_Player)->
	ok;
apply(_Board,S,_SrcPos,_Player)-> %how does this pid get here???
	io:write({strange_thing_in_apply,S}).

new(0,List,Meta,GemHolder,Cost)->
	A=fun(Board,SrcPos,Player) -> apply(Board,List,SrcPos,Player) end,
	{A,{Meta,GemHolder,Cost}};
new(N,List,Meta,GemHolder,CurrentCost)->
	case dice:getRand(2) of
		1-> {A,B,NewGems,NewCost}=newSpawn(GemHolder,CurrentCost);
		%2-> {A,B,NewGems,NewCost}=newMove(GemHolder,CurrentCost);
		2-> {A,B,NewGems,NewCost}=newCrystal(GemHolder,CurrentCost)
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
	Fun=fun(Board,SrcPos,Player)->
			
			Pos=Scatter(SrcPos),
			io:nl(),
			io:write({spawning,to,Pos}),
			permanent:create(Pos, Board, Size, Player),
			ok
	end,
	{Fun,{spawn,Size,Meta},NewGems,NewCost}.
	%adds _ and $0
newMove(Gems,N)-> %TODO FIX this funk
	{SFunc,Meta}=pos:scatterFunk(),
	FFun=fun(Board,_Pos,Player)->
			Func=fun(Src)->
					Target=SFunc(Src),
					case board:move(Board, Src, Target) of 
						hitSomething -> permanent:fight(Board, Src, Target);
						_ -> ok
				 	end,
				 Src
				 end,
			%TODO apply to entire board, only move if color is right
			%board:applyToAll(Func),
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
	FFun=fun(_Board,_Pos,Player)->cost:addCrystal(CType,Player),io:nl(),io:write({new,CType,for,Player}) end,
	{FFun,{crystal,CType},G,N+25}.
