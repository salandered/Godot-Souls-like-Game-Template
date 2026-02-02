class_name PlAnimParamsContainer
extends BaseAnimParamsContainer


# Track names
const SWITCHES_TO_QUEUE := "switches_to_queue"
const ALLOWS_QUEUE := "allows_queue"

const TRACKS_INPUT_VECTOR := "tracks_input_vector"


# If no track
const DEFAULT_PARAMS: Dictionary[String, bool] = {
	SWITCHES_TO_QUEUE: false,
	ALLOWS_QUEUE: false,
	INVINCIBLE: false,
	# INTERRUPTABLE: true,
	WEAPON_HURTS: false,
	TRACKS_INPUT_VECTOR: true,
}


## track's exact path is very fragile. see docs of PlAnimParameters
static var TRACK_PREFIXES: Array[String] = [
	"NativeAnimator/AnimParameters:",
	"%AnimParameters:",
	"../AnimatorManager/NativeAnimator/AnimParameters:",
]

func get_all_params() -> Array[String]:
	# print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return TypeCast.array_of_string(DEFAULT_PARAMS.keys())


func get_default_params() -> Dictionary[String, bool]:
	return DEFAULT_PARAMS


func get_track_prefixes() -> Array[String]:
	return TRACK_PREFIXES


#################

func is_invincible(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, INVINCIBLE, timestamp)


func is_weapon_hurts(weapon_name: String, anim: Animation, timestamp: float) -> bool:
	# for any weapon_name in player
	return _is_weapon_hurts(anim, timestamp)


func is_switches_to_queue(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, SWITCHES_TO_QUEUE, timestamp)

	
func is_allows_queue(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, ALLOWS_QUEUE, timestamp)

	
# func is_interruptable(anim: Animation, timestamp: float) -> bool:
# 	# return _get_value_from_track(anim, INTERRUPTABLE, timestamp)
# 	return true
	

func is_tracks_input_vector(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, TRACKS_INPUT_VECTOR, timestamp)

##

func _is_weapon_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, WEAPON_HURTS, timestamp)
