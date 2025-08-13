# extends LegsBehaviour

# var to_walk_treshold : float = 0.5

# ## Jog_legs_behaviour also a SM. It consists of five states: idle, start, cycle, end animations for jogging, and another state called walk_stop 
# ## (if the player started to jog, but ended it abruptly in the first 0.5 seconds of our start animation). 
# ##  (also, jogging animations are in fact sets of eight animations in a trench coat, one per forty-five degrees direction angle.)


# ## `Legs_behaviours` states have the type called `Legs_Actions`, and `legs_actions` are instantiated once and live in a shared pool instead of being a copy per behaviour. 
# ## Firstly, this helps to combat pyramidization. Our SMs don't have any doubles in their states. I use `walk_stop` and `idle` in both `jog_locomotion` cycle and in `walk_locomotion` cycle. The only doubled logic is literally this one line in behaviour description, telling me that I use the idle state here.
# var used_actions : Array[String] = [
# 	"idle",
# 	"jog_loco_start",
# 	"jog_loco_cycle",
# 	"jog_loco_stop",
# 	"walk_loco_stop",
# ]
extends Node
# func update(input : InputPackage, delta : float):
# 	choose_action(input)
# 	legs.current_action.update(input, delta)

# # if move
# #  if idle or stopping              -> start again
# #  if starting and started for long -> go for cycle
# # else stop
# #  if started early                  -> abrupt stop walk
# #  if started normally or moved cyclically -> proper stop
# #  if was stopping and stopped enough -> to idle

# func choose_action(input : InputPackage):
# 	if input.input_actions.has("move"):
# 		if ["idle", "jog_loco_stop", "walk_loco_stop"].has(legs.current_action.action_name):
# 			switch_to("jog_loco_start", input)
# 			return
# 		if legs.current_action.action_name == "jog_loco_start" and legs.current_action.animation_ended():
# 			switch_to("jog_loco_cycle", input)
# 			return
# 	else:
# 		if legs.current_action.action_name == "jog_loco_start" and legs.current_action.acts_less_than(to_walk_treshold): #  to_walk_treshold?  to_w
# 			switch_to("walk_loco_stop", input)
# 			return
# 		if ["jog_loco_start", "jog_loco_cycle"].has(legs.current_action.action_name):
# 			switch_to("jog_loco_stop", input)
# 			return
# 		if ["jog_loco_stop", "walk_loco_stop"].has(legs.current_action.action_name) and legs.current_action:
# 			switch_to("idle", input)
# 			return

# ## And a second enormous win is this little structure that works when we enter into a 
# ## newly switched legs_behaviour. If it so happens that the previous behaviour used one of our states, we don't bother switching it and instead work directly from here, analysing the next input. 
# func on_enter_behaviour(input : InputPackage):
# 	if not used_actions.has(legs.current_action.action_name):
# 		choose_initial_action(input)

# func choose_initial_action(input : InputPackage):
# 	match legs.current_action.motion_type:
# 		legs.MotionType.IDLE:
# 			switch_to("idle", input)
# 			return
# 		legs.MotionType.START:
# 			switch_to("jog_loco_cycle", input)
# 			return
# 		legs.MotionType.CYCLE:
# 			switch_to("jog_loco_cycle", input)
# 			return
# 		legs.MotionType.STOP:
# 			switch_to("idle", input)
# 			return
