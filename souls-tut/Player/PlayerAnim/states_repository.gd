extends Node
class_name StatesDataRepository

@onready var state_database: AnimationPlayer = %StatesDatabase


func get_root_delta_pos(animation: String, progress: float, delta: float) -> Vector3:
	var data = _get_animation(animation)
	var track = data.find_track("StatesDatabase:root_position", Animation.TYPE_VALUE)
	if data.track_get_key_count(track) == 0:
		return Vector3.ZERO
	var previous_pos = data.value_track_interpolate(track, progress - delta)
	var current_pos = data.value_track_interpolate(track, progress)
	var delta_pos = current_pos - previous_pos
	return delta_pos


# "ask them about the hypothetical parameter status at a given time if it was playing"
# called from player state

func get_transitions_to_queued(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:transitions_to_queued", timecode)

func get_accepts_queueing(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:accepts_queueing", timecode)

func get_vulnerable(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:is_vulnerable", timecode)

func get_interruptable(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:is_interruptable", timecode)

func get_parryable(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:is_parryable", timecode)

func get_duration(animation: String) -> float:
	return _get_animation(animation).length

func get_right_weapon_hurts(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:right_hand_weapon_hurts", timecode)

func tracks_input_vector(animation: String, timecode: float) -> bool:
	return _get_boolean_value(animation, "StatesDatabase:tracks_input_vector", timecode)


# low level methods

func _get_boolean_value(animation: String, track_name: String, timecode: float) -> bool:
	var data = _get_animation(animation)
	var track = data.find_track(track_name, Animation.TYPE_VALUE)
	if track == -1:
		push_error("Track not found: " + track_name + " in animation " + animation)
	return data.value_track_interpolate(track, timecode)

func _get_animation(animation: String) -> Animation:
	var data = state_database.get_animation(animation)
	assert(data, "No animation '" + animation + "' in states DB")
	return data
