extends RefCounted
class_name Groups


## DOCS
## example usage: 
##      func _ready() -> void:
##			add_to_group(Groups.Environment_.TARGETABLE)
##		var all_targets := get_tree().get_nodes_in_group(Groups.Environment_.TARGETABLE)

class Dev:
	const DEBUG_CAMERAS = "debug_cameras"
	const camera_mode_toggle = "camera_mode_toggle"


class Environment_:
	const TARGETABLE = "TARGETABLE"


class Player_:
	const parried_humanoid = "parried_humanoid"


class Weapons:
	const ENEMY_WEAPON = "ENEMY_WEAPON"
	const PLAYER_WEAPON = "PLAYER_WEAPON"
