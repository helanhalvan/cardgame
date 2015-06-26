%% @author David
%% @doc @todo Add description to board.


-module(board).
-behavior(supervisor).
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1,init/1]).
init(_args)->
	RestartPlan={one_for_one, 0, 10},
	Children=[],
	{ok,{RestartPlan,Children}}.
start(Opts)->
		io:write({board_starting}),

	[{size,Size},{eventReciver, EventReciver}]=option:get(Opts,[{size,{default,10}},{eventReciver,requried}]),
	{ok,Pid}=supervisor:start_link(?MODULE,asd),
	{UI,Event}=matrixUI:start({Size,Size}),%using wx

	keyValueStore:add(EventReciver, eventSrc,Event),
	
		Field={ch1,{field,start,[UI,Size]},permanent,brutal_kill,worker,dynamic},
	supervisor:start_child(Pid,Field),
	io:write({board_done}),
	{ok,Pid}.


%% ====================================================================
%% Internal functions
%% ====================================================================


