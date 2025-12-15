extends Node3D
class_name BaseLevel


func _ready() -> void:
	var nodes := get_descendants.pause_menu_controller(self)
	error_.empty_list(nodes, "no pause_menu_controller found in the level scene")
	if len(nodes) > 1:
		error_.warn("several pause_menu_controller found in the level scene. It's weird", "", "")