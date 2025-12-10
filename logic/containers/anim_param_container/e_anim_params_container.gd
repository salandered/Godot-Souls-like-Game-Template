extends Node

## Reference: Player's version
class_name EAnimParamsContainer


const VULNERABLE := "vulnerable"
const WEAPON_HURTS := "weapon_hurts"
const AURA_HURTS := "aura_hurts"


# if no track
const DEFAULT_PARAMS: Dictionary[String, bool] = {
	VULNERABLE: true,
	WEAPON_HURTS: false,
	AURA_HURTS: false
}


static func get_all_params() -> Array[String]:
	print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return TypeCast.array_of_string(DEFAULT_PARAMS.keys())


const TRACK_PREFIXES: Array[String] = [
	"%AnimParameters:",
	"AnimatorManager/NativePlayer/AnimParameters:"]


func is_vulnerable(anim: Animation, timestamp: float) -> bool:
	# return _get_value_from_track(anim, VULNERABLE, timestamp)
	return true
	

func is_weapon_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, WEAPON_HURTS, timestamp)


func is_aura_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, AURA_HURTS, timestamp)


func _get_value_from_track(anim: Animation, param: String, timestamp: float) -> bool:
	var _default: bool = u.safe_get_dict_key(DEFAULT_PARAMS, param, false)
	var _track_exists: bool = false
	for prefix in TRACK_PREFIXES:
		_track_exists = AnimUtils.is_track_exists(anim, prefix, param)
		if _track_exists:
			var _r := AnimUtils.get_bool_value_from_track(anim, prefix, param, timestamp, _default)
			return _r
	return _default
