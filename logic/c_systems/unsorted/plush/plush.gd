extends Node3D
class_name PlushCharacter


@export var float_height: float = 20.0
@export var duration: float = 10.0
## How far (in meters) the object can drift sideways (X/Z)
@export var horizontal_drift: float = 3.0


var floating_already: float = false


func start_floating():
	var tween := create_tween().set_parallel(true)
	
	# up
	tween.tween_property(self, "global_position:y", global_position.y + float_height, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)

	# drift
	# (negative to positive -> goes left OR right)
	var drift_x := randf_range(-horizontal_drift, horizontal_drift)
	var drift_z := randf_range(-horizontal_drift, horizontal_drift)
	
	tween.tween_property(self, "global_position:x", global_position.x + drift_x, duration)
	tween.tween_property(self, "global_position:z", global_position.z + drift_z, duration)

	# rot
	var random_rot := Vector3(
		randf_range(-15, 15),
		randf_range(0, 280),
		randf_range(-15, 15)
	)
	tween.tween_property(self, "rotation_degrees", rotation_degrees + random_rot, duration)

	# clean up
	tween.chain().tween_callback(queue_free)


func _on_plush_lever_sig_lever_switched() -> void:
	if not self.is_queued_for_deletion():
		if not floating_already:
			start_floating()
			floating_already = true
