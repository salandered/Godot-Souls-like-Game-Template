extends PlayerState

@export var sprint_stamina_cost = 20 # per sec so multiply by delta


func transition_logic(input: InputPackage) -> String:
	if not player.is_on_floor():
		return PS.midair
	return best_input_that_can_be_paid(input)


# func update(input: InputPackage, delta: float):
# 	# _mirror_legs_action(input)
# 	current_action.update(input, delta)

# func _mirror_legs_action(input: InputPackage):
# 	if current_action.action_name != legs_sm.current_action.action_name:
# 		switch_action_to(legs_sm.current_action.action_name, input)
#  	# else:
#  		# print_.prefix("PS |" + state_name + "|", "not switching", 5)


func on_enter_state(input: InputPackage):
	switch_action_to(PS.action_sprint, input) # overrides default in this case
