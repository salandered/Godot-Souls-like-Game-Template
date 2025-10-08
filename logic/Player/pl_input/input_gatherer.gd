extends Node
class_name InputGatherer


const LONG_PRESS_THRESHOLD: float = 0.2

var _press_timer: float = 0.0
var _long_press_triggered: bool = false


var idle_buffer_frames: int = 0 ## FOR FUTURE
var _was_running: bool = false
var _idle_frame_count: int = 0


const MIN_REVERSE_HOLD_TIME: float = 0.1
const SEQUENTIAL_PRESS_THRESHOLD: float = 0.35


var _forward_key: KeyPress = KeyPress.new()
var _back_key: KeyPress = KeyPress.new()
var _right_key: KeyPress = KeyPress.new()
var _left_key: KeyPress = KeyPress.new()


func _update_key_press_timestamps() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	_forward_key.update(RawAction.move_forward, current_time)
	_back_key.update(RawAction.move_back, current_time)
	_right_key.update(RawAction.move_right, current_time)
	_left_key.update(RawAction.move_left, current_time)


func _any_vert_pressed() -> bool:
	return _forward_key.is_pressed or _back_key.is_pressed

func _any_hor_pressed() -> bool:
	return _right_key.is_pressed or _left_key.is_pressed

func _just_pressed_and_pressed(key_1: KeyPress, key_2: KeyPress) -> bool:
	return key_1.is_just_pressed and key_2.is_pressed

func _just_pressed_and_not_pressed(key_1: KeyPress, key_2: KeyPress) -> bool:
	return key_1.is_just_pressed and not key_2.is_pressed


func _determine_turn_intent(new_input: InputPackage) -> void:
	# TODO: template both phases in a way, so its iteration over 4 pair of keys and not 4 if-s
	var reverse_data := new_input.reverse_data
	reverse_data.reset()
	
	var current_time = Time.get_ticks_msec() / 1000.0
		
	# PHASE 1: Check all overlap cases
	if _just_pressed_and_pressed(_right_key, _left_key) and not _any_vert_pressed():
		var hold_duration = _left_key.get_time_since_press(current_time)
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.LEFT], DV.name_to_vec[DV.RIGHT], "strafe", 0.0)
			return
	
	if _just_pressed_and_pressed(_left_key, _right_key) and not _any_vert_pressed():
		var hold_duration = _right_key.get_time_since_press(current_time)
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.RIGHT], DV.name_to_vec[DV.LEFT], "strafe", 0.0)
			return

	if _just_pressed_and_pressed(_back_key, _forward_key) and not _any_hor_pressed():
		var hold_duration = _forward_key.get_time_since_press(current_time)
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.FORWARD], DV.name_to_vec[DV.BACK], "forward", 0.0)
			return

	if _just_pressed_and_pressed(_forward_key, _back_key) and not _any_hor_pressed():
		var hold_duration = _back_key.get_time_since_press(current_time)
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.BACK], DV.name_to_vec[DV.FORWARD], "forward", 0.0)
			return

	# PHASE 2: Check all sequential cases if no overlap was found
	if _just_pressed_and_not_pressed(_right_key, _left_key) and not _any_vert_pressed():
		if _left_key.last_release_time > 0:
			var time_since_release = current_time - _left_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.LEFT], DV.name_to_vec[DV.RIGHT], "strafe", time_since_release)
				return

	if _just_pressed_and_not_pressed(_left_key, _right_key) and not _any_vert_pressed():
		if _right_key.last_release_time > 0:
			var time_since_release = current_time - _right_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.RIGHT], DV.name_to_vec[DV.LEFT], "strafe", time_since_release)
				return

	if _just_pressed_and_not_pressed(_back_key, _forward_key) and not _any_hor_pressed():
		if _forward_key.last_release_time > 0:
			var time_since_release = current_time - _forward_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.FORWARD], DV.name_to_vec[DV.BACK], "forward", time_since_release)
				return

	if _just_pressed_and_not_pressed(_forward_key, _back_key) and not _any_hor_pressed():
		if _back_key.last_release_time > 0:
			var time_since_release = current_time - _back_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.BACK], DV.name_to_vec[DV.FORWARD], "forward", time_since_release)
				return


func _gather_lock_target(new_input: InputPackage, delta: float):
	if Input.is_action_pressed(RawAction.lock_target):
		_press_timer += delta
		
		if not _long_press_triggered and _press_timer >= LONG_PRESS_THRESHOLD:
			_long_press_triggered = true
			print_.input_gathering("", "target_lock_LONG_pressed")
			new_input.target_lock_long_pressed = true
			_press_timer = 0.0
	
	if Input.is_action_just_released(RawAction.lock_target):
		if not _long_press_triggered:
			print_.input_gathering("", "target_lock_pressed")
			new_input.target_lock_pressed = true
		_press_timer = 0.0
		_long_press_triggered = false


func gather_input(delta: float) -> InputPackage:
	var new_input = InputPackage.new()
	_gather_lock_target(new_input, delta)
	

	_update_key_press_timestamps() # <-- Add here

	# FOR FANCY CAMERA
	new_input.forward_input = Input.get_action_strength(RawAction.move_forward) \
		- Input.get_action_strength(RawAction.move_back)
	new_input.orbit_input = Input.get_action_strength(RawAction.move_right) \
		- Input.get_action_strength(RawAction.move_left)


	# MOVE DIRECTION

	new_input.move_press.forward = Input.is_action_pressed(RawAction.move_forward)
	new_input.move_press.back = Input.is_action_pressed(RawAction.move_back)
	new_input.move_press.left = Input.is_action_pressed(RawAction.move_left)
	new_input.move_press.right = Input.is_action_pressed(RawAction.move_right)
	
	_determine_turn_intent(new_input)

	# MOVEMENT

	new_input.input_direction = Input.get_vector(
		RawAction.move_left, RawAction.move_right, RawAction.move_forward, RawAction.move_back)
	
	var _has_input = new_input.input_direction != Vector2.ZERO
	
	# MAIN
	new_input.actions.append(PS.idle) # was idle as default
	
	if _has_input:
		new_input.actions.append(PS.run)
		if Input.is_action_pressed(RawAction.sprint): # sprint is here to avoid in place sprinting
			new_input.actions.append(PS.sprint)
		_idle_frame_count = 0
		_was_running = true
	else:
		# No input this frame - check if we should postpone idle
		if _was_running and _idle_frame_count < idle_buffer_frames:
			new_input.actions.append(PS.run)
			_idle_frame_count += 1
		else:
			_was_running = false
	
	if Input.is_action_pressed(RawAction.parry):
		new_input.actions.append(PS.parry)

	if Input.is_action_pressed("withdraw"):
		new_input.actions.append(PS.withdraw)


	if Input.is_action_pressed("roll"):
		new_input.actions.append(PS.roll)

	# if Input.is_action_pressed("block"):
		# new_input.actions.append(PS.block)


	if Input.is_action_pressed("shield_throw"):
		new_input.actions.append(PS.shield_throw)

	if Input.is_action_pressed("shield_throw_reload"):
		new_input.actions.append(PS.shield_throw_reload)

	if Input.is_action_pressed(RawAction.jump):
		if new_input.actions.has(PS.sprint):
			new_input.actions.append(PS.jump_sprint)
		else:
			new_input.actions.append(PS.small_jump_run)
	
	# ATTACK
	if Input.is_action_just_pressed(RawAction.light_attack):
		new_input.combat_actions.append(CombatAction.light_attack_pressed)
	#if Input.is_action_just_pressed("heavy_attack"):
		#new_input.combat_actions.append("heavy_attack_pressed")
	

	# SYSTEM
	if Input.is_action_just_pressed(RawAction.force_quit):
		get_tree().quit()

	return new_input
