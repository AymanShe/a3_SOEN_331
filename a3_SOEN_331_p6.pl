state(State)
superstate(super, sub)
initial_state(ini,state[null if top level])
transition(source, dist,event,guard,action)
-----------------------
%%top level

state(top)
superstate(null,top)//check for correctness
initial_state(top,null)
transition(top,exit,kill,null,null)//can we kill while in lockdown


-----------------------
%%under top

superstate(top,dormant)
superstate(top,init)
superstate(top,idle)
superstate(top,monitoring)
superstate(top,error_diagnosis)
superstate(top,safe_shutdown)

state(dormant)
state(init)
state(idle)
state(monitoring)
state(error_diagnosis)
state(safe_shutdown)

initial_state(dormant,top)

transition(dormant,init,start,null,null)
transition(init,idle,init_ok,null,null)//how to check if drivers are loaded
transition(init,error_diagnosis,init_crash,null,init_err_msg)//check the action
transition(idle,monitoring,begin_monitoring,null,null)
transition(idle,eroor_diagnosis,idle_Crash,null,idle_err_msg)//check the action
transition(monitoring,error_diagnosis,monitor_crash,null,monitor_err_msg)//check the action
transition(error_diagnosis,safe_shutdown,shutdown,retry>2,retry=0)//how to change variable value
transition(error_diagnosis,monitoring,moni_rescue,null,null)//what’s the guard
transition(error_diagnosis,idle,idle_rescue,null,null)//what’s the guard
transition(error_diagnosis,init,retry_init,retry<2,retry++)//how to change variable value
transition(safe_shutdown,dormant,sleep,null,null)
---------------------------

%%under init

state(boot_hw)
state(senchk)
state(tchk)
state(psichk)
state(ready)

superstate(init,boot_hw)
superstate(init,senchk)
superstate(init,tchk)
superstate(init,psichk)
superstate(init,ready)

initial_state(boot_hw,init)

transition(boot_hw,senchk,hw_ok,null,null)
transition(senchk,tchk,senok,null,null)
transition(tchk,psichk,t_ok,null,null)
transition(psichk,ready,psi_ok,null,null)
-----------------------------

%%under monitoring

state(monidle)
state(regulate_invironment)
state(lockdown)

superstate(monitoring,monidle)
superstate(monitoring,regulate_invironment)
superstate(monitoring,lockdown)

initial_state(monidle,monitoring)

transition(monidle,regulate_invironment,no_contagion,null,null)
transition(monidle,lockdown,contagion_alert,null,[inlockdown=true,FACILITY_CRIT_MESG]) //check variable value change and action msg
transition(regulate_invironment,monidle,after_100ms,null,null)
transition(lockdown,monidle,purge_succ,null,inlockdown=false)//check variable value change
----------------------------
