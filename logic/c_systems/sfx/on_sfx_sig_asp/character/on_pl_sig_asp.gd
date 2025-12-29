## can be used as is if no logic needed
class_name OnPlayerSigASP
extends OnCharacterSigASP


func _hard_validate_implementation() -> bool:
	return self._sfx_system and self._sfx_system is PlayerSFXSystem


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	return VolPitch.new(base_vol_db, base_pitch)


## not nullable
func get_character_sfx_system() -> PlayerSFXSystem:
	return self._sfx_system as PlayerSFXSystem


## not nullable
func get_curr_action_name() -> String:
	return get_character_sfx_system().get_character().get_curr_action_name()


## __LOGS
# region


func __LOG_B() -> bool:
	return false


# endregion
