extends Node
class_name InputGatherer


const LONG_PRESS_THRESHOLD: float = 0.2

var _press_timer: float = 0.0
var _long_press_triggered: bool = false

func gather_input(delta: float) -> InputPackage:
	var new_input = InputPackage.new()

	_gather_lock_target(new_input, delta)

	# FOR FANCY CAMERA
	new_input.forward_input = Input.get_action_strength(RawAction.move_forward) \
		- Input.get_action_strength(RawAction.move_back)
	new_input.orbit_input = Input.get_action_strength(RawAction.move_right) \
		- Input.get_action_strength(RawAction.move_left)


	# MOVEMENT

	new_input.actions.append(PS.run) # was idle as default

	new_input.input_direction = Input.get_vector(
		RawAction.move_left, RawAction.move_right, RawAction.move_forward, RawAction.move_back)
	
	
	# MAIN
	if new_input.input_direction != Vector2.ZERO:
		# new_input.actions.append(PS.run)
		if Input.is_action_pressed(RawAction.sprint): # sprint is hidden here to avoid standing in place and sprinting
			new_input.actions.append(PS.sprint)
	
	if Input.is_action_pressed(RawAction.parry):
		new_input.actions.append(PS.parry)

	if Input.is_action_pressed("withdraw"):
		new_input.actions.append(PS.withdraw)


	if Input.is_action_pressed("roll"):
		new_input.actions.append(PS.roll)

	if Input.is_action_pressed("block"):
		new_input.actions.append(PS.block)


	if Input.is_action_pressed("shield_throw"):
		new_input.actions.append(PS.shield_throw)

	if Input.is_action_pressed("shield_throw_reload"):
		new_input.actions.append(PS.shield_throw_reload)

	if Input.is_action_pressed(RawAction.jump):
		if new_input.actions.has(PS.sprint):
			new_input.actions.append(PS.jump_sprint)
		else:
			new_input.actions.append(PS.jump_run)
	
	# ATTACK
	if Input.is_action_just_pressed(RawAction.light_attack):
		new_input.combat_actions.append(CombatAction.light_attack_pressed)
	#if Input.is_action_just_pressed("heavy_attack"):
		#new_input.combat_actions.append("heavy_attack_pressed")
	

	# SYSTEM
	if Input.is_action_just_pressed(RawAction.force_quit):
		get_tree().quit()

	return new_input


func _gather_lock_target(new_input: InputPackage, delta: float):
	if Input.is_action_pressed(RawAction.lock_target):
		_press_timer += delta
		
		if not _long_press_triggered and _press_timer >= LONG_PRESS_THRESHOLD:
			_long_press_triggered = true
			print("[input] target_lock_LONG_pressed")
			new_input.target_lock_long_pressed = true
			_press_timer = 0.0
	
	if Input.is_action_just_released(RawAction.lock_target):
		if not _long_press_triggered:
			print("[input] target_lock_pressed")
			new_input.target_lock_pressed = true
		_press_timer = 0.0
		_long_press_triggered = false