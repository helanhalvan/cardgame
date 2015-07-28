%% @author David
%% @doc @todo Add description to playerMover.


-module(playerMover).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1]).
	start(Options)->
			io:write({moverStarting}),
			[{moveTickTime,MaxSpeed},{hp,Size}]=option:get(Options,[{moveTickTime,{default,1}},{hp,{default,100}}]),
			[{resHolder,Holder}]=option:get(Options,[{resHolder,required}]),

			{board,Field}=keyValueStore:get(Holder,board),

			[{color,Color}]=option:get(Options,[{color,required}]),

			[{pos,Pos}]=option:get(Options,[{pos,required}]),
			Pid=spawn_link(fun()->init(Field,Pos,Size,Color,MaxSpeed) end),
	{ok,Pid}.


%% ====================================================================
%% Internal functions
%% ====================================================================
init(Field,Pos,Size,Color,MaxSpeed)->
		Pid=self(),
		OverLord=self(),%%TODO this shod be a players controlled thing
		
		Entity=fieldEntity:spawn(Field,Pos,Size,Color,Pid),
		utils:pacemaker(fun()->Pid ! go end, MaxSpeed),
		io:write({moverDone}),
		ready(Entity,OverLord).		
		
% nothingToMove
% hitSomething
% outOfBounds
ready(Entity,OverLord)->
	receive
		A when ( (A==up) or (A==down) or (A==left) or (A==right) )->  fieldEntity:move(Entity,A),wait(Entity,OverLord);
		nothingToMove->OverLord ! died, ok; 
		{hitSomething,_Something,Here} -> fieldEntity:fight(Entity,Here);
		_ -> ready(Entity,OverLord)
	end.

wait(Entity,OverLord)->
	receive
		go->ready(Entity,OverLord);
		_ -> wait(Entity,OverLord)
	end.