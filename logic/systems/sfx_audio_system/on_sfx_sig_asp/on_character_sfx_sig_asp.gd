extends OnSFXSigASP
class_name OnCharacterSFXSigASP


func _character_sfx_system() -> CharacterSFXSystem:
	return self._sfx_system as CharacterSFXSystem


func _validate():
	assert(self._sfx_system is CharacterSFXSystem)


func _custom_logic(signal_data: Dictionary[String, Variant]) -> void:
	pass


## __LOGS
# region

func pp_name() -> String:
	return "OnCharacterSFXSigASP"

func __LOG_B() -> bool:
	return false


func __LOG_INDENT() -> int:
	return 6

# endregion
