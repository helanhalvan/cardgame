%% @author David
%% @doc @todo Add description to player.


-module(player).

-behavior(supervisor).
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1,init/1]).

start(Options)->
	%simply pass all options to both sub prossess
	{ok,Pid}=supervisor:start_link(?MODULE, na),
	io:write({playerStarting}),

	Mover={mover,{playerMover,start,[Options]},permanent,brutal_kill,worker,dynamic},
	{ok,MPid}=supervisor:start_child(Pid,Mover),
	io:write({player20}),
	Op2=lists:flatten([Options|[{posSrc,MPid}]]),
	Caster={caster,{playerCaster,start,[Op2]},permanent,brutal_kill,worker,dynamic},
	{ok,CPid}=supervisor:start_child(Pid,Caster),
	io:write({player25}),

	[{resHolder,Holder}]=option:get(Options,[{resHolder,required}]), 
	[{controls,KeyBinds}]=option:get(Options,[{controls,required}]),
	io:write({player30}),
	{eventSrc,KeyListner}=keyValueStore:get(Holder,eventSrc),
	io:write({player50}),
	Callback1=utils:makeKeyCallback(CPid,KeyBinds),
	Callback2=utils:makeKeyCallback(MPid,KeyBinds),
	%Callback2=fun(A)->MPid ! down end,
	io:write({player75}),
	keyListner:register(Callback1, KeyListner),
	keyListner:register(Callback2, KeyListner),

	io:write({player100}),
	{ok,Pid}.
	
init(_args)->
	%currently there is no reason to try to restart after a component fails
	RestartPlan={one_for_all, 0, 120},
	Children=[],
	{ok,{RestartPlan,Children}}.


%spawn(Game,Options)->
%na.
%turn into paramter list
%record for player
%spawn(Deck,KeyListner,HandBinds, StartHandSize,%for the deck
%	MoveBinds,Board,Pos,Side,Hp,ETickTime,MoveTickTime)->%for the movement
%	CurrentPos=playerMover:start(Board, Pos, KeyListner, Side, Hp, MoveBinds,[{maxSpeed,MoveTickTime}]),
%	playerCaster:start(Deck,KeyListner,HandBinds,StartHandSize,CurrentPos,Side,Board,ETickTime).
	
%spawn(Deck,KeyListner,HandBinds, StartHandSize,%for the deck
%	MoveBinds,Board,Pos,Side,Hp,ETickTime)->%for the movement
%	CurrentPos=playerMover:start(Board, Pos, KeyListner, Side, Hp, MoveBinds,[]),
%	playerCaster:start(Deck,KeyListner,HandBinds,StartHandSize,CurrentPos,Side,Board,ETickTime).
%% ====================================================================
%% Internal functions
%% ====================================================================


