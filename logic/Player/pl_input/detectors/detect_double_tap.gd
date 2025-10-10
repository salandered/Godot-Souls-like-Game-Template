extends BaseDetector
class_name TapDetector

var _threshold: float
var _is_waiting := false
var _wait_start_time := 0.0

var _tap_this_frame := false
var _double_tap_this_frame := false


func _init(threshold_: float) -> void:
	_threshold = threshold_


## The main update function to be called every frame.
## It processes the key state and updates the internal flags.
func update(key: KeyPress, current_time: float) -> void:
	_reset_flags()

	# A 'just_pressed' event is the trigger for our main logic.
	if key.is_just_pressed:
		# If we're waiting and this new press is fast enough, it's a double tap.
		if _is_waiting and _is_valid_double_tap(key, current_time):
			_double_tap_this_frame = true
			_is_waiting = false # The sequence is complete.
		# Otherwise, if we are NOT waiting, this is the first tap of a new sequence.
		elif not _is_waiting:
			_is_waiting = true
			_wait_start_time = current_time
		# NOTE: If we are waiting but the tap is too slow, we do nothing with this
		# 'just_pressed' event and let the timer expire naturally.
	
	# The timeout check for a single tap runs independently.
	# If the 'just_pressed' logic didn't cancel the wait, this will catch it.
	if _is_waiting and current_time - _wait_start_time > _threshold:
		_tap_this_frame = true # Time's up, it was just a single tap.
		_is_waiting = false # The sequence is complete.


func tap_happened() -> bool:
	return _tap_this_frame


func double_tap_happened() -> bool:
	return _double_tap_this_frame


## Returns true if a tap has occurred and the detector is waiting to see if it's a double tap.
## Useful for providing instant feedback (e.g., sound) on the first press.
func is_waiting_for_confirmation() -> bool:
	return _is_waiting


func _reset_flags() -> void:
	_tap_this_frame = false
	_double_tap_this_frame = false


## Internal check to see if a key press qualifies as the second tap in a sequence.
func _is_valid_double_tap(key: KeyPress, current_time: float) -> bool:
	if key.is_just_pressed and key.was_released_at_least_one():
		var time_since_release = current_time - key.last_release_time
		if time_since_release <= _threshold:
			return true
	return false
