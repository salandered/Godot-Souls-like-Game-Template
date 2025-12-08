extends BaseDetector

## seems like non static would be easier
class_name DetectReverse


const MIN_REVERSE_HOLD_TIME: float = 0.1
const SEQUENTIAL_PRESS_THRESHOLD: float = 0.35
## how long to keep detecting reversal after second key pressed
## 0.15 is ~9 frames
const MAX_REVERSE_OVERLAP_TIME: float = 0.18


class DirectionalKeys:
	var forward_key: KeyPress
	var back_key: KeyPress
	var left_key: KeyPress
	var right_key: KeyPress

	func _init(_forward: KeyPress, _back: KeyPress, _left: KeyPress, _right: KeyPress):
		forward_key = _forward
		back_key = _back
		left_key = _left
		right_key = _right


static func _any_vert_pressed(keys: DirectionalKeys) -> bool:
	return keys.forward_key.is_pressed or keys.back_key.is_pressed

static func _any_hor_pressed(keys: DirectionalKeys) -> bool:
	return keys.right_key.is_pressed or keys.left_key.is_pressed


static func _check_overlap(k_just_pressed: KeyPress, k_pressed: KeyPress, all_keys: DirectionalKeys, action_to_vector: Dictionary,
	reverse_data: ReverseData, type: ReverseData.ReverseType) -> bool:
	var other_keys_are_pressed: bool
	if type == ReverseData.ReverseType.HORIZONTAL:
		other_keys_are_pressed = _any_vert_pressed(all_keys)
	else: # ReverseData.ReverseType.VERTICAL
		other_keys_are_pressed = _any_hor_pressed(all_keys)

	# FIRST FRAME: catch the initial reversal press
	if _just_pressed_and_pressed(k_just_pressed, k_pressed):
		var hold_duration := k_pressed.get_time_since_press(_current_time())
		# print_.input_gathering("🕵🏻Reverse Detection FIRST FRAME", pp.s(hold_duration, MIN_REVERSE_HOLD_TIME))
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			var from_vector = action_to_vector[k_pressed.raw_action]
			var to_vector = action_to_vector[k_just_pressed.raw_action]

			reverse_data.initialise(from_vector, to_vector, type, 0.0, other_keys_are_pressed)
			return true
	
	# SUBSEQUENT FRAMES: catch reversal while both keys held (extended window)
	var k_ex_just_pressed = k_just_pressed # we look for a key that was just pressed several frames ago (and still pressed ofc)
	if _pressed_and_pressed(k_ex_just_pressed, k_pressed):
		var old_key_duration := k_pressed.get_time_since_press(_current_time())
		var new_key_duration := k_ex_just_pressed.get_time_since_press(_current_time())
		# print_.input_gathering("🕵🏻Reverse Detection EXTENDED", pp.s(old_key_duration, MIN_REVERSE_HOLD_TIME, new_key_duration, MAX_REVERSE_OVERLAP_TIME))
		# same check for k_pressed, ex just pressed key must be recent
		if old_key_duration >= MIN_REVERSE_HOLD_TIME and new_key_duration < MAX_REVERSE_OVERLAP_TIME:
			var from_vector = action_to_vector[k_pressed.raw_action]
			var to_vector = action_to_vector[k_ex_just_pressed.raw_action]

			reverse_data.initialise(from_vector, to_vector, type, 0.0, other_keys_are_pressed)
			return true
			
	return false


static func _check_sequential(k_just_pressed: KeyPress, k_not_pressed: KeyPress, all_keys: DirectionalKeys, action_to_vector: Dictionary,
	reverse_data: ReverseData, type: ReverseData.ReverseType) -> bool:
	var other_keys_are_pressed: bool
	if type == ReverseData.ReverseType.HORIZONTAL:
		other_keys_are_pressed = _any_vert_pressed(all_keys)
	else: # ReverseData.ReverseType.VERTICAL
		other_keys_are_pressed = _any_hor_pressed(all_keys)

	if _just_pressed_and_not_pressed(k_just_pressed, k_not_pressed):
		if k_not_pressed.was_released_at_least_one():
			var time_since_release := _current_time() - k_not_pressed.last_release_time
			# print_.input_gathering("🕵🏻Reverse Detection SEQUENTIAL", pp.s(time_since_release, SEQUENTIAL_PRESS_THRESHOLD))
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				var from_vector = action_to_vector[k_not_pressed.raw_action]
				var to_vector = action_to_vector[k_just_pressed.raw_action]
				
				reverse_data.initialise(from_vector, to_vector, type, time_since_release, other_keys_are_pressed)
				return true
				
	return false


static func detect_reverse_data(new_input: InputPackage,
	forward_key: KeyPress,
	back_key: KeyPress,
	right_key: KeyPress,
	left_key: KeyPress,
	delta: float
) -> void:
	var reverse_data := new_input.reverse_data
	reverse_data.reset()

	var all_keys := DirectionalKeys.new(forward_key, back_key, left_key, right_key)
	
	var action_to_vector := {
		forward_key.raw_action: Vector2(0, -1),
		back_key.raw_action: Vector2(0, 1),
		left_key.raw_action: Vector2(-1, 0),
		right_key.raw_action: Vector2(1, 0)
	}

	# PHASE 1: Check all overlap cases
	if _check_overlap(right_key, left_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.HORIZONTAL): return
	if _check_overlap(left_key, right_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.HORIZONTAL): return
	if _check_overlap(back_key, forward_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.VERTICAL): return
	if _check_overlap(forward_key, back_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.VERTICAL): return

	# PHASE 2: Check all sequential cases
	if _check_sequential(right_key, left_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.HORIZONTAL): return
	if _check_sequential(left_key, right_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.HORIZONTAL): return
	if _check_sequential(back_key, forward_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.VERTICAL): return
	if _check_sequential(forward_key, back_key, all_keys, action_to_vector, reverse_data, ReverseData.ReverseType.VERTICAL): return
