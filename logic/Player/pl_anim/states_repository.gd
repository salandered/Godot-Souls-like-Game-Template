extends Node
class_name StatesDataRepository

@onready var state_db: StatesDatabase = %StatesDatabase
@onready var animation_player: AnimationPlayer = %AnimationPlayer


# "ask them about the hypothetical parameter status at a given time if it was playing"

# Param DOCS are in states_db.gd

var _fail_if_no_anim: bool = true
var _warn_no_param_anim_found: bool = false


const DEFAULT_PARAMS := {
	state_db.TRANSITIONS_TO_QUEUED: false,
	state_db.ACCEPTS_QUEUEING: false,
	state_db.IS_PARRYABLE: false,
	state_db.IS_VULNERABLE: true,
	state_db.IS_INTERRUPTABLE: true,
	state_db.WEAPON_HURTS: false,
	state_db.TRACKS_INPUT_VECTOR: true,
	state_db.ROOT_MOTION: false,
}


func get_duration(anim_name: String) -> float:
	# TODO TODO bad bad
	if anim_name == "-":
		return 0
	var anim := state_db.get_anim(anim_name)
	if not anim:
		if _warn_no_param_anim_found: print(anim_name + " wasnt found, using len of real animation")
		return _get_len_using_original_anim(anim_name)

	if anim.length == 0:
		push_error("Empty anim_name! not good!")
		
	return anim.length


func get_transitions_to_queued(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.TRANSITIONS_TO_QUEUED, timecode)

func get_accepts_queueing(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.ACCEPTS_QUEUEING, timecode)

func get_parryable(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.IS_PARRYABLE, timecode)

func get_vulnerable(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.IS_VULNERABLE, timecode)

func get_interruptable(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.IS_INTERRUPTABLE, timecode)

func get_weapon_hurts(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.WEAPON_HURTS, timecode)

func get_tracks_input_vector(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.TRACKS_INPUT_VECTOR, timecode)

func get_root_motion(anim_name: String, timecode: float) -> bool:
	return _get_boolean_value(anim_name, state_db.ROOT_MOTION, timecode)


# low level methods
func _get_boolean_value(anim_name: String, param_name: String, timecode: float) -> bool:
	var anim: Animation = state_db.get_anim(anim_name)
	if not anim:
		if _warn_no_param_anim_found: print(anim_name + " wasn found, using default values")
		return DEFAULT_PARAMS[param_name]

	var track_name = state_db.STATES_DB + ":" + param_name
	var track = anim.find_track(track_name, Animation.TYPE_VALUE)
	if track == -1:
		push_error("Track not found: " + track_name + " in animation " + anim_name)
		return DEFAULT_PARAMS[param_name]
	return anim.value_track_interpolate(track, timecode)


func _get_len_using_original_anim(anim_name: String) -> float:
	# param animation can be lost, but real one must be there
	u.assert_has_animation(animation_player, anim_name, false)
	return animation_player.get_animation(anim_name).length
