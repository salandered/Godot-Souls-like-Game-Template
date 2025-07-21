extends Node3D
class_name Targetable_

@export var parent : Node3D

@onready var look_at_point = $LookAt

func _ready():
	add_to_group("targetable")
