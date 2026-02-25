class_name Groups
extends RefCounted

## NOTE: im not quite sure about the naming convention and granularity.
	 ## should be refactored based on usage patterns

## DOCS
## example usage: 
##      func _ready() -> void:
##			add_to_group(Groups.Environment_.TARGETABLE)
##		var all_targets := get_tree().get_nodes_in_group(Groups.Environment_.TARGETABLE)


class Dev:
	const DEBUG_CAMERAS = "debug_cameras"
	const camera_mode_toggle = "camera_mode_toggle"
	const FANCY_CAM = "fancy_cam"
	const SK_ANIM_MANAGER = "SK_ANIM_MANAGER"
	const DEV_VISUALS = "DEV_VISUALS"
	const DV_LEG_TURN = "DV_LEG_TURN"


class Marker:
	const LOOK_AT = "LOOK_AT"


class Environment_:
	const TARGETABLE = "TARGETABLE"
	const LEVEL = "LEVEL"


class Chars:
	const PLAYER = "PLAYER"
	const BIG_GUY = "BIG_GUY"
	const BASE_CHARACTER = "BASE_CHARACTER"
	const BASE_ENEMY_CHARACTER = "BASE_ENEMY_CHARACTER"
	const SIMPLE_ENEMY = "SIMPLE_ENEMY"


class Weapons:
	const ENEMY_WEAPON = "ENEMY_WEAPON"
	const PLAYER_WEAPON = "PLAYER_WEAPON"


static func get_player_by_group(for_whom: Node) -> Princess:
	var player := for_whom.get_tree().get_first_node_in_group(Groups.Chars.PLAYER)
	if not player or player is not Princess:
		return
	return player as Princess
	
static func get_first_phe_bg_by_group(for_whom: Node) -> BigGuyCharacter:
	var e := for_whom.get_tree().get_first_node_in_group(Groups.Chars.BIG_GUY)
	if not e or e is not BigGuyCharacter:
		return
	return e as BigGuyCharacter

static func get_phe_bg_by_group(for_whom: Node) -> Array[BigGuyCharacter]:
	var e_s := for_whom.get_tree().get_nodes_in_group(Groups.Chars.BIG_GUY)
	var filtered: Array[BigGuyCharacter]
	for item in e_s:
		if item is BigGuyCharacter:
			filtered.append(item)
	return filtered


static func get_first_phe_bg_by_group_with_tag(for_whom: Node, tag: StringName) -> BigGuyCharacter:
	var e_s := for_whom.get_tree().get_nodes_in_group(Groups.Chars.BIG_GUY)
	for item in e_s:
		if item is BigGuyCharacter:
			var casted := item as BigGuyCharacter
			if casted.dev_tag == tag:
				return casted
	return null


static func get_first_se_by_group(for_whom: Node) -> MechFighter:
	var e := for_whom.get_tree().get_first_node_in_group(Groups.Chars.SIMPLE_ENEMY)
	if not e or e is not MechFighter:
		return
	return e as MechFighter
	
	
static func get_level_by_group(for_whom: Node) -> BaseLevel:
	var level = for_whom.get_tree().get_first_node_in_group(Groups.Environment_.LEVEL)
	if not level or not level is BaseLevel:
		return
	return level as BaseLevel


static func get_first_pl_mod_animator_by_group(for_whom: Node) -> PlayerModifierAnimator:
	var _r := for_whom.get_tree().get_first_node_in_group(Groups.Dev.SK_ANIM_MANAGER)
	if not _r or _r is not PlayerModifierAnimator:
		return
	return _r as PlayerModifierAnimator

static func get_first_leg_turn_by_group(for_whom: Node) -> TurnData:
	var _r := for_whom.get_tree().get_first_node_in_group(Groups.Dev.DV_LEG_TURN)
	if not _r or _r is not TurnData:
		return
	return _r as TurnData


static func get_dv(for_whom: Node) -> Array[Node]:
	var dvs := for_whom.get_tree().get_nodes_in_group(Groups.Dev.DEV_VISUALS)
	return dvs