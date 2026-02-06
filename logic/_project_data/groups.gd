class_name Groups
extends RefCounted

## NOTE: im not quite sure about the naming convention and dont know how it all will be used. 
## 		so it's all raw

## DOCS
## example usage: 
##      func _ready() -> void:
##			add_to_group(Groups.Environment_.TARGETABLE)
##		var all_targets := get_tree().get_nodes_in_group(Groups.Environment_.TARGETABLE)

class Dev:
	const DEBUG_CAMERAS = "debug_cameras"
	const camera_mode_toggle = "camera_mode_toggle"

class Marker:
	const LOOK_AT = "LOOK_AT"

class Environment_:
	const TARGETABLE = "TARGETABLE"
	const LEVEL = "LEVEL"


class Chars:
	const PLAYER = "PLAYER"
	const BASE_CHARACTER = "BASE_CHARACTER"
	const BASE_ENEMY_CHARACTER = "BASE_ENEMY_CHARACTER"


class Weapons:
	const ENEMY_WEAPON = "ENEMY_WEAPON"
	const PLAYER_WEAPON = "PLAYER_WEAPON"


static func get_player_by_group(for_whom: Node) -> Princess:
	var player = for_whom.get_tree().get_first_node_in_group(Groups.Chars.PLAYER)
	if not player or player is not Princess:
		return
	return player as Princess
	
	
static func get_level_by_group(for_whom: Node) -> BaseLevel:
	var level = for_whom.get_tree().get_first_node_in_group(Groups.Environment_.LEVEL)
	if not level or not level is BaseLevel:
		return
	return level as BaseLevel