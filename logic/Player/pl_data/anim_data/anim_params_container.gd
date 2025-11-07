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
const DEFAULT_PARAMS := {
	SWITCHES_TO_QUEUE: false,
	ALLOWS_QUEUE: false,
	VULNERABLE: true,
	INTERRUPTABLE: true,
	WEAPON_HURTS: false,
	TRACKS_INPUT_VECTOR: true,
}


static func get_all_params() -> Array[String]:
	print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return u.safe_cast_array_of_strings(DEFAULT_PARAMS.keys())


const TRACK_PREFIX := "%AnimParameters:"


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
	var _default = u.safe_get_dict_key(DEFAULT_PARAMS, param, false)
	var _r := AnimUtils.get_bool_value_from_track(anim, TRACK_PREFIX, param, timestamp, _default)
	return _r
