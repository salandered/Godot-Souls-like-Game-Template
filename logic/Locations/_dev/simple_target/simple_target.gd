extends Node3D

@export var label: String
@onready var camera_target: EnemyCameraTarget = %CameraTarget


func _ready() -> void:
	if not label:
		label = str(get_path())
	camera_target.label = label
	
	camera_target.initialise(self)
