extends OnCharacterSFXSignalPlayer
class_name OnCharacterSFXFootStepSignalPlayer


var FOOTSTEP_BASE_VOL: float = -6.0
var RUN_TIME_TO_LOWER_FOOTSTEP_VOL: float = 0.5
var LIGHT_FOOTSTEP_VOL_DECREASE: float = 5.0
var SPRINT_FOOTSTEP_VOL_INCREASE: float = 12.0
var SPRINT_FOOTSTEP_PITCH_INCREASE: float = 0.25


func _custom_logic(signal_data: Dictionary) -> void:
	var pitch = 1.0
	var vol_db = FOOTSTEP_BASE_VOL
	
	if signal_data.has(SfxType.modifier_key):
		var modifier: String = signal_data[SfxType.modifier_key]
		if modifier == SfxType.Modifier.light:
			vol_db -= LIGHT_FOOTSTEP_VOL_DECREASE
	var _curr_state := _character_audio_system().get_character().get_current_state()
	if _curr_state == null:
		pass
	else:
		var _curr_state_name := _curr_state.state_name
		var _prev_state_name := _character_audio_system().get_character().get_prev_state_name()
		var _run_state_name := _character_audio_system().get_character_run_state_name()
		var _sprint_state_name := _character_audio_system().get_character_sprint_state_name()
		match _curr_state_name:
			_sprint_state_name:
				pitch += SPRINT_FOOTSTEP_PITCH_INCREASE
				vol_db += SPRINT_FOOTSTEP_VOL_INCREASE
			_run_state_name when not _prev_state_name in [_sprint_state_name]:
				if _curr_state.get_actual_time_spent() < RUN_TIME_TO_LOWER_FOOTSTEP_VOL:
					# prints(em.mark_x2)
					pitch -= 0.05
					vol_db -= LIGHT_FOOTSTEP_VOL_DECREASE
	
	__log_("result vol/pitch", vol_db, pitch)
	stream_player.volume_db = vol_db
	stream_player.pitch_scale = pitch + randf_range(-0.02, 0.02)


## __LOGS
# region

func pp_name() -> String:
	return "OnCharacterSFXFootStepSignalPlayer"

func __LOG_B() -> bool:
	return false


func __LOG_INDENT() -> int:
	return 6

# endregion
# endregion
