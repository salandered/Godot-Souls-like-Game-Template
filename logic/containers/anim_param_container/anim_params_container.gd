extends Node

## TODO: may be switching to anim_id and getting it using AnimContainer
## to make this feel more like repository, and not a util getter (right now it could be been static class)
class_name AnimParamsContainer


# Track names
const SWITCHES_TO_QUEUE := "switches_to_queue"
const ALLOWS_QUEUE := "allows_queue"
const VULNERABLE := "vulnerable"
const INTERRUPTABLE := "interruptable"
const WEAPON_HURTS := "weapon_hurts"
const TRACKS_INPUT_VECTOR := "tracks_input_vector"


# If no track
const DEFAULT_PARAMS: Dictionary[String, bool] = {
	SWITCHES_TO_QUEUE: false,
	ALLOWS_QUEUE: false,
	VULNERABLE: true,
	INTERRUPTABLE: true,
	WEAPON_HURTS: false,
	TRACKS_INPUT_VECTOR: true,
}


static func get_all_params() -> Array[String]:
	print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return TypeCast.array_of_string(DEFAULT_PARAMS.keys())


## track's exact path is very fragile. see docs of PlAnimParameters
static var TRACK_PREFIXES: Array[String] = [
	"%AnimParameters:",
	"../AnimatorManager/NativeAnimator/AnimParameters:",
	"NativeAnimator/AnimParameters:"
]


func is_switches_to_queue(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, SWITCHES_TO_QUEUE, timestamp)

	
func is_allows_queue(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, ALLOWS_QUEUE, timestamp)

	
func is_vulnerable(anim: Animation, timestamp: float) -> bool:
	# return _get_value_from_track(anim, VULNERABLE, timestamp)
	return true
	

func is_interruptable(anim: Animation, timestamp: float) -> bool:
	# return _get_value_from_track(anim, INTERRUPTABLE, timestamp)
	return true
	

func is_weapon_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, WEAPON_HURTS, timestamp)


func is_tracks_input_vector(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, TRACKS_INPUT_VECTOR, timestamp)


func _get_value_from_track(anim: Animation, param: String, timestamp: float) -> bool:
	var _default: bool = u.safe_get_dict_key(DEFAULT_PARAMS, param, false)
	var _track_exists: bool = false
	for prefix in TRACK_PREFIXES:
		_track_exists = AnimUtils.is_track_exists(anim, prefix, param)
		if _track_exists:
			var _r := AnimUtils.get_bool_value_from_track(anim, prefix, param, timestamp, _default)
			return _r
	return _default
