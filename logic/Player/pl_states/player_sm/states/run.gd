extends PlayerState

## we have a main state called run, and it uses the legs behavior called run_legs. 
## in container set for run state legs_behavior = RunLegs Node


func check_transition(input: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	return best_input_that_can_be_paid(input)

# func choose_default_action() -> String:
# 	if not legs_sm.current_action:
# 		push_error("something wrong")
# 	var name_ = legs_sm.current_action.action_name
# 	if not name_:
# 		push_error("something wrong")
# 	return name_

# func update(input: InputPackage, delta: float):
	# current_action = legs_sm.current_action
	# _mirror_legs_action(input)
	# current_action.update(input, delta)

# func _mirror_legs_action(input: InputPackage):
# 	if current_action.action_name != legs_sm.current_action.action_name:
# 		print_.psm("mirror", state_name + ": " + current_action.action_name + " -> legs's " + legs_sm.current_action.action_name, 1)
# 		switch_action_to(legs_sm.current_action.action_name, input)
# 	# else:
# 		# print_.prefix("PS  |" + state_name + "|", "not switching", 5)

# func animate(_input: InputPackage):
# 	player_sm.torso_animator.sync_and_follow(legs_sm.legs_animator, 0.15)

# TODO: do we need it? certainly not here
func on_exit_state():
	# of course the same animator. in perfect world legs_sm.legs_animator to var
	legs_sm.legs_animator.remove_follower()
