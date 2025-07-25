extends Node
class_name InputGatherer

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()

	# FOR FANCY CAMERA
	new_input.forward_input = Input.get_action_strength(InAction.move_forward) \
		- Input.get_action_strength(InAction.move_back)
	new_input.orbit_input = Input.get_action_strength(InAction.move_right) \
		- Input.get_action_strength(InAction.move_left)
	
	# MAIN
	new_input.actions.append(InDataAction.idle)

	new_input.input_direction = Input.get_vector(
		InAction.move_left, InAction.move_right, InAction.move_forward, InAction.move_back)
	
	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append(InDataAction.run)
		if Input.is_action_pressed(InAction.sprint): # sprint is hidden here to avoid standing in place and sprinting
			new_input.actions.append(InDataAction.sprint)
	
	if Input.is_action_pressed(InAction.parry):
		new_input.actions.append(InDataAction.parry)

	if Input.is_action_pressed(InAction.jump):
		if new_input.actions.has(InDataAction.sprint):
			new_input.actions.append(InDataAction.jump_sprint)
		else:
			new_input.actions.append(InDataAction.jump_run)
	
	if Input.is_action_just_pressed(InAction.light_attack):
		new_input.combat_actions.append(InDataCombatAction.light_attack_pressed)
	
	# SYSTEM
	if Input.is_action_just_pressed(InAction.force_quit):
		get_tree().quit()

	return new_input

	# if Input.is_action_just_pressed("hit"):
	# 	new_input.actions.append("hit")
	
	# if Input.is_action_just_pressed("roll"):
	# 	new_input.actions.append("roll")
		
	# if Input.is_action_just_pressed("dash"):
	# 	new_input.actions.append("dash")
