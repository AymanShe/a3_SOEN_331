%state(state)
%superstate(super, sub)
%initial_state(ini,state[null if top level])
%transition(source, dist,event,guard,action)
%findall(Variable,target(rule),list)

%are transition to exit needed?
%--------------------
%top level

state(top).
initial_state(top,null).
transition(top,exit,kill,no_guard,null).%can we kill while in lockdown+ a transition to exit



%-----------------------
%under top

superstate(top,dormant).
superstate(top,init).
superstate(top,idle).
superstate(top,monitoring).
superstate(top,error_diagnosis).
superstate(top,safe_shutdown).

state(dormant).
state(init).
state(idle).
state(monitoring).
state(error_diagnosis).
state(safe_shutdown).

initial_state(dormant,top).

transition(dormant,init,start,no_guard,null).
transition(init,idle,init_ok,no_guard,null).%how to check if drivers are loaded
transition(init,error_diagnosis,init_crash,no_guard,init_err_msg).%check the action
transition(idle,monitoring,begin_monitoring,no_guard,null).
transition(idle,eroor_diagnosis,idle_Crash,no_guard,idle_err_msg).%check the action
transition(monitoring,error_diagnosis,monitor_crash,no_guard,monitor_err_msg).%check the action
transition(error_diagnosis,safe_shutdown,shutdown,Retry>2,Retry=0).%how to change variable value
transition(error_diagnosis,monitoring,moni_rescue,no_guard,null).%what’s the guard
transition(error_diagnosis,idle,idle_rescue,no_guard,null).%what’s the guard
transition(error_diagnosis,init,retry_init,Retry<2,Retry+1).%how to change variable value
transition(safe_shutdown,dormant,sleep,no_guard,null).
%---------------------------

%under init

state(boot_hw).
state(senchk).
state(tchk).
state(psichk).
state(ready).

superstate(init,boot_hw).
superstate(init,senchk).
superstate(init,tchk).
superstate(init,psichk).
superstate(init,ready).

initial_state(boot_hw,init).

transition(boot_hw,senchk,hw_ok,no_guard,null).
transition(senchk,tchk,senok,no_guard,null).
transition(tchk,psichk,t_ok,no_guard,null).
transition(psichk,ready,psi_ok,no_guard,null).
%-----------------------------

%under monitoring

state(monidle).
state(regulate_invironment).
state(lockdown).

superstate(monitoring,monidle).
superstate(monitoring,regulate_invironment).
superstate(monitoring,lockdown).

initial_state(monidle,monitoring).

transition(monidle,regulate_invironment,no_contagion,no_guard,null).
transition(monidle,lockdown,contagion_alert,no_guard,'Inlockdown=true,FACILITY_CRIT_MESG'). %check variable value change and action msg
transition(regulate_invironment,monidle,after_100ms,no_guard,null).
transition(lockdown,monidle,purge_succ,no_guard,Inlockdown=false).%check variable value change
%----------------------------

%under lockdown

state(prep_vpurge).
state(alt_temp).
state(alt_psi).
state(risk_assess).
state(safe_status).

superstate(lockdown,prep_vpurge).
superstate(lockdown,alt_temp).
superstate(lockdown,alt_psi).
superstate(lockdown,risk_assess).
superstate(lockdown,safe_status).

initial_state(prep_vpurge,lockdown).

transition(prep_vpurge,alt_temp,initiate_purge,no_guard,lockdoors).
transition(prep_vpurge,alt_psi,initiate_purge,no_guard,lockdoors).
transition(alt_temp,risk_assess,tcyc_comp,no_guard,null).
transition(alt_psi,risk_assess,psicyc_comp,no_guard,null).
transition(risk_assess,prep_vpurge,no_event,Risk>0.01,null).
transition(risk_assess,safe_status,no_event,Risk<0.01,unlock_doors).
%----------------------------

%under error diagnosis

state(error_rcv).
state(applicable_rescue).
state(reset_module_data).

superstate(error_diagnosis,error_rcv).
superstate(error_diagnosis,applicable_rescue).
superstate(error_diagnosis,reset_module_data).

initial_state(error_rcv,error_diagnosis).

transition(error_rcv,applicable_rescue,no_event,Err_protocol_def=true,null).
transition(error_rcv,reset_module_data,no_event,Err_protocol_def=false,null).
transition(applicable_rescue,exit,apply_protocol_rescue,no_guard,null).%a transition to exit
transition(reset_module_data,exit,reset_to_stable,no_guard,null).%a transition to exit
%--------------------------------
is_loop(Event,Guard):-
	transition(State,State,Event,Guard,_).
all_loops(Set):-
	findall([Event,Guard],is_loop(Event,Guard),L),
	list_to_set(L,Set).
is_edge(Event,Guard):-
	transition(_,_,Event,Guard,_).
size(Length):-
	findall([Event,Guard],is_edge(Edge,Guard),L),
	length(L,Length),
	Result is Length.
is_link(Event,Guard):-
	transition(S,D,Event,Guard,_),
	(S\==D).
all_superstates(Set):-
	findall(Superstate,superstate(Superstate,_),L),
	list_to_set(L,Set).	
ancestor(Ancestor,Descendant):-
	superstate(Ancestor,Descendant).
inherits_transitions(State, List):-
	superstate(Super,State),
	findall([Super,Distination,Event,Gurad,Action],transition(Super,Distination,Event,Gurad,Action),List).
all_states(L):-
	findall(State,state(State),L).
all_init_states(L):-
	findall(State,initial_state(State,_),L).
get_starting_state(State):-
	initial_state(State,null).
state_is_reflexive(State):-
	transition(State,State,_,_,_).
graph_is_reflexive:-
	state(State),
	state_is_reflexive(State).	
get_guards(Set):-
	findall(Guard,transition(_,_,_,Guard,_),L),
	list_to_set(L,Set).
get_events(Set):-
	findall(Event,transition(_,_,Event,_,_),L),
	list_to_set(L,Set).
get_actions(Set):-
	findall(Action,transition(_,_,_,_,Action),L),
	list_to_set(L,Set).
get_only_guarded(Set):-
	findall([State1,State2],(transition(State1,State2,no_event,Guard,null),Guard\=no_guard),L),%actions are null or _
	list_to_set(L,Set).
legal_events_of(State,L):-
	findall([Event,Guard],(transition(State,_,Event,Guard,_),(Event\=no_event;Guard\=no_guard)),List),
	list_to_set(List,L).

