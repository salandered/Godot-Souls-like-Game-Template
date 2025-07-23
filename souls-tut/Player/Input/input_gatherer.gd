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
		new_input.actions.append(InputPackageAction.run)
		if Input.is_action_pressed(InputAction.sprint): # sprint is hidden here to avoid standing in place and sprinting
			new_input.actions.append(InputPackageAction.sprint)
	
	if Input.is_action_pressed(InputAction.jump):
		if new_input.actions.has(InputPackageAction.sprint):
			new_input.actions.append(InputPackageAction.jump_sprint)
		else:
			new_input.actions.append(InputPackageAction.jump_run)
	
	if Input.is_action_just_pressed(InputAction.light_attack):
		new_input.combat_actions.append(InputPackageCombatAction.light_attack_pressed)
	
	if new_input.actions.is_empty():
		new_input.actions.append(InputPackageAction.idle)

	# SYSTEM
	if Input.is_action_just_pressed(InputAction.force_quit):
		get_tree().quit()


	return new_input

	# if Input.is_action_just_pressed("hit"):
	# 	new_input.actions.append("hit")
	
	# if Input.is_action_just_pressed("roll"):
	# 	new_input.actions.append("roll")
		
	# if Input.is_action_just_pressed("dash"):
	# 	new_input.actions.append("dash")
