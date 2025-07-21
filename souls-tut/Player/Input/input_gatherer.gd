extends Node
class_name InputGatherer

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()

	# FOR FANCY CAMERA
	new_input.forward_input = Input.get_action_strength(InputAction.move_forward) \
		- Input.get_action_strength(InputAction.move_back)
	new_input.orbit_input = Input.get_action_strength(InputAction.move_right) \
		- Input.get_action_strength(InputAction.move_left)
	
	# 'IF' ORDER MATTERS
	new_input.input_direction = Input.get_vector(
		InputAction.move_left, InputAction.move_right, InputAction.move_forward, InputAction.move_back)
	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append(InputDataAction.run)
		if Input.is_action_pressed(InputAction.sprint): # sprint is hidden here to avoid standing in place and sprinting
			new_input.actions.append(InputDataAction.sprint)
	
	if Input.is_action_pressed(InputAction.jump):
		if new_input.actions.has(InputDataAction.sprint):
			new_input.actions.append(InputDataAction.jump_sprint)
		else:
			new_input.actions.append(InputDataAction.jump_run)
	
	if Input.is_action_just_pressed(InputAction.light_attack):
		new_input.combat_actions.append(InputDataAction.light_attack_pressed)
	
	if new_input.actions.is_empty():
		new_input.actions.append(InputDataAction.idle)

	return new_input

	# if Input.is_action_just_pressed("hit"):
	# 	new_input.actions.append("hit")
	
	# if Input.is_action_just_pressed("roll"):
	# 	new_input.actions.append("roll")
		
	# if Input.is_action_just_pressed("dash"):
	# 	new_input.actions.append("dash")
