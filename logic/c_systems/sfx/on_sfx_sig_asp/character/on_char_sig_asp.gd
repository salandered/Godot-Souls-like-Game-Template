## can be used as is if no logic needed
class_name OnCharacterSigASP
extends OnSFXSigASP


## CHARACTER SPECIFIC


func _hard_validate_implementation() -> bool:
	return self._sfx_system and self._sfx_system is CharacterSFXSystem


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	return VolPitch.new(base_vol_db, base_pitch)


## Character Helpers

## not nullable
func get_character_sfx_system() -> CharacterSFXSystem:
	return self._sfx_system as CharacterSFXSystem


## not nullable
func get_character() -> BaseCharacter:
	var _char := get_character_sfx_system().get_character()
	return _char


## nullable
func get_curr_state() -> BaseCharacterState:
	var _curr_state := get_character_sfx_system().get_character().get_current_state()
	return _curr_state


func get_curr_state_name() -> String:
	var _curr_state := get_character_sfx_system().get_character().get_current_state()
	if _curr_state == null:
		return ""
	else:
		return _curr_state.state_name

func get_prev_state_name() -> String:
	return get_character_sfx_system().get_character().get_prev_state_name()


## __LOGS
# region


func __LOG_B() -> bool:
	return false

# endregion
