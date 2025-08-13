# extends LegsBehaviour

# var used_actions : Array[String] = [
# 	"sprint",
# 	"jog_loco_cycle",
# 	"jog_loco_stop",
# 	"idle",
# ]

# func update(input : InputPackage, delta : float):
# 	choose_action(input)
# 	legs.current_action.update(input, delta)
extends Node
# func choose_action(input : InputPackage):
# 	if legs.current_action.action_name == "sprint" and legs.current_action.acts_longer_than(0.6):
# 		switch_to("jog_loco_cycle", input)
# 		return
# 	if legs.current_action.action_name == "jog_loco_cycle" and legs.current_action.acts_longer_th:
# 		switch_to("jog_loco_stop", input)
# 		return
# 	if legs.current_action.action_name == "jog_loco_stop" and legs.current_action.acts_longer_tha:
# 		switch_to("idle", input)
# 		return

# func on_enter_behaviour(input : InputPackage):
# 	choose_initial_action(input)

# # TODO work with momentum when it will be refactored back into the system
# func choose_initial_action(input : InputPackage):
# 	if ["sprint"].has(legs.current_action.action_name):
# 		switch_to("sprint", input)
# 		return
# 	if ["jog_loco_start", "jog_loco_cycle"].has(legs.current_action.action_name):
# 		switch_to("jog_loco_cycle", input)
# 		return
# 	switch_to("idle", input)
