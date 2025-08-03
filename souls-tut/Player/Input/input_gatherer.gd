extends Node
class_name InputGatherer

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()

	# FOR FANCY CAMERA
	new_input.forward_input = Input.get_action_strength(InAction.move_forward) \
		- Input.get_action_strength(InAction.move_back)
	new_input.orbit_input = Input.get_action_strength(InAction.move_right) \
		- Input.get_action_strength(InAction.move_left)

	if Input.is_action_just_released("lock_target"):
		new_input.target_lock = true
	
	# MAIN
	new_input.actions.append(PlayerState.idle)

	new_input.input_direction = Input.get_vector(
		InAction.move_left, InAction.move_right, InAction.move_forward, InAction.move_back)
	
	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append(PlayerState.run)
		if Input.is_action_pressed(InAction.sprint): # sprint is hidden here to avoid standing in place and sprinting
			new_input.actions.append(PlayerState.sprint)
	
	if Input.is_action_pressed(InAction.parry):
		new_input.actions.append(PlayerState.parry)


	if Input.is_action_pressed("withdraw"):
		new_input.actions.append("withdraw")


	if Input.is_action_pressed("roll"):
		new_input.actions.append("roll")
	
	if Input.is_action_pressed("block"):
		new_input.actions.append("block")


	if Input.is_action_pressed("shield_throw"):
		new_input.actions.append("shield_throw")
	
	if Input.is_action_pressed("shield_throw_reload"):
		new_input.actions.append("shield_throw_reload")
		
	if Input.is_action_pressed(InAction.jump):
		if new_input.actions.has(PlayerState.sprint):
			new_input.actions.append(PlayerState.jump_sprint)
		else:
			new_input.actions.append(PlayerState.jump_run)
	
	if Input.is_action_just_pressed(InAction.light_attack):
		new_input.combat_actions.append(InDataCombatAction.light_attack_pressed)
	#if Input.is_action_just_pressed("heavy_attack"):
		#new_input.combat_actions.append("heavy_attack_pressed")
	
	# SYSTEM
	if Input.is_action_just_pressed(InAction.force_quit):
		get_tree().quit()

	return new_input
