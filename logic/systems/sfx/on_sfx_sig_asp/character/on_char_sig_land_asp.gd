class_name OnCharSigLandASP
extends OnCharacterSigASP


var FOOTSTEP_BASE_VOL: float = -6.0
var PITCH_BASE_VOL: float = 1.0

var DODGE_LAND_DECREASE: float = 3.0


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	var pitch := PITCH_BASE_VOL
	var vol_db := FOOTSTEP_BASE_VOL

	var _curr_state_name := get_curr_state_name()
	var _prev_state_name := get_prev_state_name()
	var _dodge_state_name := get_character().get_dodge_state_names()

	if _curr_state_name in get_character().get_dodge_state_names():
		vol_db -= DODGE_LAND_DECREASE
	

	return VolPitch.new(base_vol_db, base_pitch)

## __LOGS
# region

func pp_name() -> String:
	return "OnCharSigLandASP"


func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
