extends Node

## Reference: Player's version
class_name EAnimParamsContainer


const VULNERABLE := "is_vulnerable"
const WEAPON_HURTS := "is_weapon_hurts"
const AURA_HURTS := "is_aura_hurts"


# if no track
const DEFAULT_PARAMS := {
	VULNERABLE: true,
	WEAPON_HURTS: false,
	AURA_HURTS: false
}


static func get_all_params() -> Array[String]:
	print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return u.safe_cast_array_of_strings(DEFAULT_PARAMS.keys())


# const TRACK_PREFIX := "%AnimParameters:"
const TRACK_PREFIX := "AnimatorManager/NativePlayer/AnimParameters:"


func is_vulnerable(anim: Animation, timestamp: float) -> bool:
	# return _get_value_from_track(anim, VULNERABLE, timestamp)
	return true
	

func is_weapon_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, WEAPON_HURTS, timestamp)


func is_aura_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, AURA_HURTS, timestamp)


func _get_value_from_track(anim: Animation, param: String, timestamp: float) -> bool:
	var _default = u.safe_get_dict_key(DEFAULT_PARAMS, param)
	if _default == null:
		_default = false
	var _r := AnimUtils.get_bool_value_from_track(anim, TRACK_PREFIX, param, timestamp, _default)
	return _r
