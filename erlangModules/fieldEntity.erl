%% @author David
%% @doc @todo Add description to fieldEntity.


-module(fieldEntity).

%% ====================================================================
%% API functions
%% ====================================================================
-export([spawn/5,move/2,getPos/1]).

spawn(Field,Pos,Size,Color,Listner)->
	field:spawn(Field,Pos,{Color,Size}),
	spawn_link(fun()->loop(Pos,Field,Listner)end).
%Dir are: up | down | left | right
move(Entity,Dir)->
		Entity ! Dir.
getPos(Entity)->
	Caller=utils:makeCaller(),
	Entity ! {wantPos,Caller},
	utils:waitForAck(Caller).
%% ====================================================================
%% Internal functions
%% ====================================================================

loop({X,Y}=Pos,Field,Listner)->
	NewPos=
	(receive
		left->sendReport(Listner,Field,Pos,{X,Y-1});
		right->sendReport(Listner,Field,Pos,{X,Y+1});
		up->sendReport(Listner,Field,Pos,{X-1,Y});
		down->sendReport(Listner,Field,Pos,{X+1,Y});
		{wantPos,Caller}->utils:sendMsg(Caller, Pos);
		{fight,Pos2}->permanent:fight(Field,Pos,Pos2)
	end),
	loop(NewPos,Field,Listner).

sendReport(Listner,Field,Src,Target)->
	case field:move(Field,Src,Target) of
		ok->Target;
		A->Listner ! A,Src
	end.
	