extends Node


@export var plush_scene: PackedScene


@export var float_height: float = 20.0
@export var duration: float = 10.0
## How far (in meters) the object can drift sideways (X/Z)
@export var horizontal_drift: float = 3.0


@onready var plush_marker_3d: Marker3D = %PlushMarker3D


func _on_plush_lever_sig_lever_switched() -> void:
	if plush_scene:
		var plush_ := plush_scene.instantiate()
		if plush_ and plush_ is PlushCharacter:
			var casted_plush: PlushCharacter = plush_
			add_child(casted_plush)
			casted_plush.float_height = float_height
			casted_plush.duration = duration
			casted_plush.horizontal_drift = horizontal_drift
			casted_plush.global_position.y = plush_marker_3d.global_position.y
			casted_plush.global_position.z = plush_marker_3d.global_position.z
			casted_plush.global_position.x = plush_marker_3d.global_position.x + randf_range(-125, 125)
			casted_plush.start_floating()
