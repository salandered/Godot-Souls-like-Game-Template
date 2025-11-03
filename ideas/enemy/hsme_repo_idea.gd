extends Node
class_name GundyrStatesData

# @onready var state_database = $MoveDatabase as AnimationPlayer


# func get_root_delta_pos(animation: String, progress: float, delta: float) -> Vector3:
# 	var data := state_database.get_animation(animation)
# 	if not data:
# 		push_error("Animation not found in database: " + animation)
# 		return Vector3.ZERO

# 	var track_index = data.find_track("MoveDatabase:root_position", Animation.TYPE_VALUE)

# 	if track_index == -1:
# 		# Return a zero vector if the root motion track doesn't exist.
# 		# This prevents the game from crashing and is a safe default.
# 		return Vector3.ZERO

# 	var previous_pos = data.value_track_interpolate(track_index, progress - delta)
# 	var current_pos = data.value_track_interpolate(track_index, progress)
# 	return current_pos - previous_pos


# func get_parryable(animation: String, timecode: float) -> bool:
# 	return _get_boolean_value(animation, "MoveDatabase:is_parryable", timecode)

# func is_attacking(weapon: String, animation: String, timecode: float) -> bool:
# 	var track_name = "MoveDatabase:" + weapon + "_hurts"
# 	return _get_boolean_value(animation, track_name, timecode)


# func _get_boolean_value(animation_name: String, track_name: String, timecode: float) -> bool:
# 	var data = state_database.get_animation(animation_name)
# 	if not data:
# 		push_error("Animation not found in database: " + animation_name)
# 		return false

# 	var track_index = data.find_track(track_name, Animation.TYPE_VALUE)

# 	if track_index == -1:
# 		return false

# 	return data.value_track_interpolate(track_index, timecode)

# func get_halberd_hurts(animation: String, timecode: float) -> bool:
# 	return is_attacking("halberd", animation, timecode)

# func get_shoulder_hurts(animation: String, timecode: float) -> bool:
# 	return is_attacking("shoulder", animation, timecode)

# func get_kick_hurts(animation: String, timecode: float) -> bool:
# 	return is_attacking("kick", animation, timecode)

# func get_aura_hurts(animation: String, timecode: float) -> bool:
# 	return is_attacking("aura", animation, timecode)
