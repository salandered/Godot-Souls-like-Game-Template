class_name OnCharFSSigASP
extends OnCharacterSigASP


var SPRINT_FOOTSTEP_VOL_INCREASE: float = 1.5
var SPRINT_FOOTSTEP_PITCH_INCREASE: float = 0.15

var RUN_START_FOOTSTEP_VOL_DECREASE: float = 2.0
var RUN_TIME_TO_LOWER_FOOTSTEP_VOL: float = 0.5


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[StringName, Variant]) -> VolPitch:
	var _curr_state := get_curr_state()
	if _curr_state == null:
		pass
	else:
		var _curr_state_name := get_curr_state_name()
		var _prev_state_name := get_prev_state_name()

		if _curr_state_name in get_character().get_sprint_state_names():
			base_pitch += SPRINT_FOOTSTEP_PITCH_INCREASE
			base_vol_db += SPRINT_FOOTSTEP_VOL_INCREASE
		elif _curr_state_name in get_character().get_run_state_names() and \
			 not _prev_state_name in get_character().get_sprint_state_names():
				if _curr_state.get_actual_time_spent() < RUN_TIME_TO_LOWER_FOOTSTEP_VOL:
					base_vol_db -= RUN_START_FOOTSTEP_VOL_DECREASE

	return VolPitch.new(base_vol_db, base_pitch)
