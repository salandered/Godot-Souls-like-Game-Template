extends Node3D
class_name BaseLevel


func _ready() -> void:
	var nodes := get_descendants.pause_menu_controller(self)
	if len(nodes) == 0:
		print_.warn(true, "no pause_menu_controller found in the level scene", "", "")
	if len(nodes) > 1:
		print_.warn(true, "several pause_menu_controller found in the level scene. It's weird", "", "")