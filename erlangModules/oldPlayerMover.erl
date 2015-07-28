%% @author David
%% @doc @todo Add description to playerMover.


-module(oldPlayerMover).
-compile(export_all).
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/7]).
%resoponsible for reporting death of the player
% and handling player movement
% optional arguments
%{maxSpeed,MS} (squares/second)

%requires that there is something to move at Pos
start(Board,Pos,KeyListner,KeyBinds,[])->
	OnDeath=spawnToBoard(Board,Pos,Size,Side),
	
	Pid=spawn_link(fun()->loop(Pos,{Board,OnDeath}) end),
	
	fixKeyBinds(KeyBinds,KeyListner,Pid),
	Pid;
start(Board,Pos,KeyListner,Side,Size,KeyBinds,[{maxSpeed,MS}])->

	OnDeath=spawnToBoard(Board,Pos,Size,Side),
	
	Pid=spawn_link(fun()->maxSpeedLoop(Pos,none,{Board,OnDeath}) end),
	
	fixKeyBinds(KeyBinds,KeyListner,Pid),
	Pid.


%% ====================================================================
%% Internal functions
%% ====================================================================
spawnToBoard(Board,Pos,Size,Side)->
	Ref=make_ref(),
	permanent:create(Pos, Board, Size, Side,[player,Ref]),
	fun()->side:remove(Ref, Side) end.

fixKeyBinds(KeyBinds,KeyListner,Pid)->
	Callback=utils:makeKeyCallback(Pid,KeyBinds),
	keyListner:register(Callback, KeyListner).
maxSpeedLoop(nil,_,_)->ok;
maxSpeedLoop(Pos,Dir,SD)->
	receive 
		tick->NewPos=maxMove(Pos,Dir,SD),NewDir=Dir;
		left->NewDir=left,NewPos=Pos;
		right->NewDir=right,NewPos=Pos;
		up->NewDir=up,NewPos=Pos;
		down->NewDir=down,NewPos=Pos;
		{where,A,Ref}->A ! {Ref,Pos},NewPos=Pos,NewDir=Dir;
		Strange->io:write({playerMoverGot,Strange}),NewPos=Pos,NewDir=Dir
	end,
	maxSpeedLoop(NewPos,NewDir,SD).
maxMove(Pos,Dir,{Board,OnDeath}=_SD)->
		Target=pos:dir(Pos, 1, Dir),
	%TODO pos:dir	
		case move(Pos,Target,Board) of 
			nothingToMove ->io:write({Pos,died,line67_playerMover}),OnDeath(),nil;
			hitSomething -> permanent:fight(Board, Pos, Target),Pos;
			ok->Target;
			_->Pos
		end.

loop({X,Y}=Pos,{_Board,OnDeath}=StaticData) when is_function(OnDeath,0)->
	receive 
		left->move(Pos,{X,Y-1},StaticData);
		right->move(Pos,{X,Y+1},StaticData);
		up->move(Pos,{X-1,Y},StaticData);
		down->move(Pos,{X+1,Y},StaticData);
		{where,A,Ref}->A ! {Ref,Pos},loop(Pos,StaticData);
			Strange->io:write({playerMoverGot,Strange}),loop(Pos,StaticData)
	end.
move(Src,Target,{Board,OnDeath}=SD)->
  case board:move(Board,Src,Target) of
	  	hitSomething -> permanent:fight(Board, Src, Target),loop(Src,SD);
	  	nothingToMove -> io:write({Src,died,line82_playerMover}),OnDeath();
	  	ok->loop(Target,SD);
		_ -> loop(Src,SD)
  end;
move(Src,Target,Board)->
	board:move(Board, Src, Target).

