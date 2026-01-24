@abstract
class_name BaseAnimParamsContainer
extends NodeLogger


const VULNERABLE := "vulnerable"
const WEAPON_HURTS := "weapon_hurts"
const AURA_HURTS := "aura_hurts"
const INTERRUPTABLE := "interruptable"


@abstract func get_all_params() -> Array[String]


@abstract func get_default_params() -> Dictionary[String, bool]


@abstract func get_track_prefixes() -> Array[String]


@abstract func is_weapon_hurts(weapon_name: String, anim: Animation, timestamp: float) -> bool


## default
func is_vulnerable(anim: Animation, timestamp: float) -> bool:
	return true


func _get_value_from_track(anim: Animation, param: String, timestamp: float) -> bool:
	var _default: bool = DictUtils.safe_get_dict_key(get_default_params(), param, false)
	var _track_exists: bool = false
	for prefix in get_track_prefixes():
		_track_exists = AnimUtils.is_track_exists(anim, prefix, param)
		if _track_exists:
			var _r := AnimUtils.get_bool_value_from_track(anim, prefix, param, timestamp, _default)
			return _r
	return _default
