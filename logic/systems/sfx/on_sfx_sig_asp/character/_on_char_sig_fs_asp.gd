@abstract
class_name OnCharFootStepSigASP
extends OnCharacterSigASP


var LIGHT_FOOTSTEP_VOL_DECREASE: float = 5.0
var SPRINT_FOOTSTEP_VOL_INCREASE: float = 12.0
var SPRINT_FOOTSTEP_PITCH_INCREASE: float = 0.25

var RUN_TIME_TO_LOWER_FOOTSTEP_VOL: float = 0.5


@abstract func _change_fs_vol(curr_vol_db: float) -> float


func _change_vol_on_light_footstep(curr_vol_db: float) -> float:
	return curr_vol_db - LIGHT_FOOTSTEP_VOL_DECREASE


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	base_vol_db = _change_fs_vol(base_vol_db)

	if get_modifier_from_payload(payload) == SFXConstants.Modifier.light:
		base_vol_db -= LIGHT_FOOTSTEP_VOL_DECREASE

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
					# prints(em.mark_x2)
					base_pitch -= 0.05
					base_vol_db = _change_vol_on_light_footstep(base_vol_db)

	return VolPitch.new(base_vol_db, base_pitch)


## __LOGS
# region


func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
