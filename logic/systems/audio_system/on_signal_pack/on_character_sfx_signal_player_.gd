extends OnSFXSignalPlayer
class_name OnCharacterSFXSignalPlayer


func _character_audio_system() -> CharacterAudioSystem:
	return self._audio_system as CharacterAudioSystem


func _validate():
	assert(self._audio_system is CharacterAudioSystem)


func _custom_logic(signal_data: Dictionary) -> void:
	pass


## __LOGS
# region

func pp_name() -> String:
	return "OnCharacterSFXSignalPlayer"

func __LOG_B() -> bool:
	return false


func __LOG_INDENT() -> int:
	return 6

# endregion
# endregion
