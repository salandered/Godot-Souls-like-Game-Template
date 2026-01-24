extends RefCounted
class_name InputGatherer

# TODO: it should be in state logic, while InputGatherer is more transparent
const SPRINT_TO_RUN_DELAY: float = 0.16

var _to_run_after_sprint_timer: SimpleTimer = SimpleTimer.new()

const DOUBLE_TAP_THRESHOLD: float = 0.24

var _jump_key: KeyPress = KeyPress.new(RawAction.jump)
var _forward_key: KeyPress = KeyPress.new(RawAction.move_forward)
var _back_key: KeyPress = KeyPress.new(RawAction.move_back)
var _right_key: KeyPress = KeyPress.new(RawAction.move_right)
var _left_key: KeyPress = KeyPress.new(RawAction.move_left)
var _target_lock_key: KeyPress = KeyPress.new(RawAction.lock_target)
var _light_attack_key: KeyPress = KeyPress.new(RawAction.light_attack)
var _heavy_attack_key: KeyPress = KeyPress.new(RawAction.heavy_attack)
var _sprint_key: KeyPress = KeyPress.new(RawAction.sprint)

var _target_lock_detector: TapDetector = TapDetector.new(DOUBLE_TAP_THRESHOLD)


func _current_time() -> float:
	return u.get_curr_time_ticks_sec()

func _update_key_press_timestamps() -> void:
	var _curr_time := _current_time()
	
	_jump_key.update(_curr_time)
	_forward_key.update(_curr_time)
	_back_key.update(_curr_time)
	_right_key.update(_curr_time)
	_left_key.update(_curr_time)
	_target_lock_key.update(_curr_time)
	_light_attack_key.update(_curr_time)
	_heavy_attack_key.update(_curr_time)
	_sprint_key.update(_curr_time)

func _detect_double_tap(key: KeyPress) -> bool:
	if key.is_just_pressed and key.was_released_at_least_one():
		var time_since_release := _current_time() - key.last_release_time
		if time_since_release <= DOUBLE_TAP_THRESHOLD:
			return true
	return false


func gather_input(delta: float) -> InputPackage:
	var new_input := InputPackage.new()

	_update_key_press_timestamps()

	# DETECT PRESS COMBINATIONS

	DetectReverse.detect_reverse_data(new_input, _forward_key, _back_key, _right_key, _left_key, delta)
	
	_target_lock_detector.update(_target_lock_key, _current_time())
	if _target_lock_detector.is_waiting_for_confirmation():
		# print_.input_gathering("", "tap has occurred; waiting to see if it's a double tap")
		new_input.target_lock.tap_waiting = true
	if _target_lock_detector.tap_happened():
		print_.input_gathering("", "target_lock tap detected")
		new_input.target_lock.tap = true
	if _target_lock_detector.double_tap_happened():
		print_.input_gathering("", "target_lock_double_tap detected")
		new_input.target_lock.double_tap = true

	# MOVEMENT

	new_input.forward_input = Input.get_action_strength(RawAction.move_forward) \
		- Input.get_action_strength(RawAction.move_back)
	new_input.orbit_input = Input.get_action_strength(RawAction.move_right) \
		- Input.get_action_strength(RawAction.move_left)


	new_input.input_direction = Input.get_vector(
		RawAction.move_left, RawAction.move_right, RawAction.move_forward, RawAction.move_back)
	
	var _has_input := new_input.input_direction != Vector2.ZERO
	
	# LOCO

	if _to_run_after_sprint_timer.is_in_progress():
		_to_run_after_sprint_timer.update(delta)

	new_input.actions.append(PS.idle)

	if _has_input or new_input.reverse_data.is_reversed():
		new_input.actions.append(PS.run)
		
		if _sprint_key.is_pressed:
			new_input.actions.append(PS.sprint)
			_to_run_after_sprint_timer.turn_off() # cancel timer if sprint is pressed again
		
		elif _sprint_key.is_just_released:
			_to_run_after_sprint_timer.initialise(SPRINT_TO_RUN_DELAY)
			new_input.actions.append(PS.sprint) # keep sprinting for this frame
		
		elif _to_run_after_sprint_timer.is_in_progress():
			new_input.actions.append(PS.sprint) # continue sprinting
		
	else: # no input this frame
		_to_run_after_sprint_timer.turn_off() # cancel timer if no moving
		
	
	if Input.is_action_just_pressed(RawAction.jump):
		if new_input.actions.has(PS.sprint):
			new_input.actions.append(PS.jump_sprint)
		else:
			# NOTE: raw action is jump but we translate to dodge
			new_input.actions.append(PS.dodge)
	 
	# ATTACK

	if _light_attack_key.is_just_pressed:
		new_input.combat_actions.append(CombatAction.light_attack_pressed)

	if _heavy_attack_key.is_just_pressed:
		new_input.combat_actions.append(CombatAction.heavy_attack_pressed)

	if _light_attack_key.is_just_pressed:
		new_input.combat_actions.append(CombatAction.light_attack_pressed)
		if new_input.actions.has(PS.run) or new_input.actions.has(PS.sprint):
			new_input.combat_actions.append(CombatAction.light_attack_pressed_when_move)
	

	return new_input
