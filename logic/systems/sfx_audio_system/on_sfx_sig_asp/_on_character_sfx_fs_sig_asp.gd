@abstract
class_name BaseOnCharacterSFXFootStepSigASP
extends OnCharacterSFXSigASP


var FOOTSTEP_BASE_VOL: float = -6.0
var PITCH_BASE_VOL: float = 1.0

var LIGHT_FOOTSTEP_VOL_DECREASE: float = 5.0
var SPRINT_FOOTSTEP_VOL_INCREASE: float = 12.0
var SPRINT_FOOTSTEP_PITCH_INCREASE: float = 0.25

var RUN_TIME_TO_LOWER_FOOTSTEP_VOL: float = 0.5


@abstract func _change_vol(curr_vol_db: float) -> float


func _change_vol_on_light_footstep(curr_vol_db: float) -> float:
	return curr_vol_db - LIGHT_FOOTSTEP_VOL_DECREASE


func _custom_logic(signal_data: Dictionary[String, Variant]) -> void:
	var pitch := PITCH_BASE_VOL
	var vol_db := FOOTSTEP_BASE_VOL
	vol_db = _change_vol(vol_db)

	if signal_data.has(SFXConstants.modifier_key):
		var modifier: Variant = signal_data[SFXConstants.modifier_key]
		if modifier is String and modifier == SFXConstants.Modifier.light:
			vol_db -= LIGHT_FOOTSTEP_VOL_DECREASE
	var _curr_state := _character_sfx_system().get_character().get_current_state()
	if _curr_state == null:
		pass
	else:
		var _curr_state_name := _curr_state.state_name
		var _prev_state_name := _character_sfx_system().get_character().get_prev_state_name()
		var _run_state_name := _character_sfx_system().get_character_run_state_name()
		var _sprint_state_name := _character_sfx_system().get_character_sprint_state_name()
		match _curr_state_name:
			_sprint_state_name:
				pitch += SPRINT_FOOTSTEP_PITCH_INCREASE
				vol_db += SPRINT_FOOTSTEP_VOL_INCREASE
			_run_state_name when not _prev_state_name in [_sprint_state_name]:
				if _curr_state.get_actual_time_spent() < RUN_TIME_TO_LOWER_FOOTSTEP_VOL:
					# prints(em.mark_x2)
					pitch -= 0.05
					vol_db = _change_vol_on_light_footstep(vol_db)
	

	__log_("result vol/pitch", vol_db, pitch)
	asp.volume_db = vol_db
	asp.pitch_scale = pitch + randf_range(-0.02, 0.02)


## __LOGS
# region


func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
