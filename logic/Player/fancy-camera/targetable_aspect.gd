extends Node3D
class_name Targetable_

@export var parent: Node3D
var label: String = "not assigned"

@onready var look_at_point = $LookAt

func _ready() -> void:
	add_to_group(Groups.Environment_.TARGETABLE)
