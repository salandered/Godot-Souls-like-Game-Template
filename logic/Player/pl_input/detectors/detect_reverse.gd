extends BaseDetector
class_name DetectReverse


const MIN_REVERSE_HOLD_TIME: float = 0.1
const SEQUENTIAL_PRESS_THRESHOLD: float = 0.35


static func _any_vert_pressed(forward_key, back_key) -> bool:
	return forward_key.is_pressed or back_key.is_pressed

static func _any_hor_pressed(right_key, left_key) -> bool:
	return right_key.is_pressed or left_key.is_pressed


static func detect_reverse_data(new_input: InputPackage,
	forward_key: KeyPress,
	back_key: KeyPress,
	right_key: KeyPress,
	left_key: KeyPress,
	delta: float
) -> void:
	# TODO: template both phases in a way, so its iteration over 4 pair of keys and not 4 if-s
	var reverse_data := new_input.reverse_data
	reverse_data.reset()
	
			
	# PHASE 1: Check all overlap cases
	if _just_pressed_and_pressed(right_key, left_key) and not _any_vert_pressed(forward_key, back_key):
		var hold_duration = left_key.get_time_since_press(_current_time())
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.LEFT], DV.name_to_vec[DV.RIGHT], "strafe", 0.0)
			return

	if _just_pressed_and_pressed(left_key, right_key) and not _any_vert_pressed(forward_key, back_key):
		var hold_duration = right_key.get_time_since_press(_current_time())
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.RIGHT], DV.name_to_vec[DV.LEFT], "strafe", 0.0)
			return

	if _just_pressed_and_pressed(back_key, forward_key) and not _any_hor_pressed(right_key, left_key):
		var hold_duration = forward_key.get_time_since_press(_current_time())
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.FORWARD], DV.name_to_vec[DV.BACK], "forward", 0.0)
			return

	if _just_pressed_and_pressed(forward_key, back_key) and not _any_hor_pressed(right_key, left_key):
		var hold_duration = back_key.get_time_since_press(_current_time())
		if hold_duration >= MIN_REVERSE_HOLD_TIME:
			reverse_data.initialise(DV.name_to_vec[DV.BACK], DV.name_to_vec[DV.FORWARD], "forward", 0.0)
			return

	# PHASE 2: Check all sequential cases if no overlap was found
	if _just_pressed_and_not_pressed(right_key, left_key) and not _any_vert_pressed(forward_key, back_key):
		if left_key.was_released_at_least_one():
			var time_since_release = _current_time() - left_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.LEFT], DV.name_to_vec[DV.RIGHT], "strafe", time_since_release)
				return

	if _just_pressed_and_not_pressed(left_key, right_key) and not _any_vert_pressed(forward_key, back_key):
		if right_key.was_released_at_least_one():
			var time_since_release = _current_time() - right_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.RIGHT], DV.name_to_vec[DV.LEFT], "strafe", time_since_release)
				return

	if _just_pressed_and_not_pressed(back_key, forward_key) and not _any_hor_pressed(right_key, left_key):
		if forward_key.was_released_at_least_one():
			var time_since_release = _current_time() - forward_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.FORWARD], DV.name_to_vec[DV.BACK], "forward", time_since_release)
				return

	if _just_pressed_and_not_pressed(forward_key, back_key) and not _any_hor_pressed(right_key, left_key):
		if back_key.was_released_at_least_one():
			var time_since_release = _current_time() - back_key.last_release_time
			if time_since_release <= SEQUENTIAL_PRESS_THRESHOLD:
				reverse_data.initialise(DV.name_to_vec[DV.BACK], DV.name_to_vec[DV.FORWARD], "forward", time_since_release)
				return
