extends OnSFXSignalPlayer
class_name OnWeaponSFXSignalPlayer


func _character_audio_system() -> BaseWeaponAudioSystem:
	return self._audio_system as BaseWeaponAudioSystem


func _validate():
	assert(self._audio_system is BaseWeaponAudioSystem)


func _custom_logic(signal_data: Dictionary[String, Variant]) -> void:
	pass


## __LOGS
# region

func pp_name() -> String:
	return "OnWeaponSFXSignalPlayer"

func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
# endregion
