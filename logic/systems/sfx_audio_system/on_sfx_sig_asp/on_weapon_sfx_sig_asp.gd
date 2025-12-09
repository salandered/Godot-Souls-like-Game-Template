extends OnSFXSigASP
class_name OnWeaponSFXSigASP


func _character_sfx_system() -> BaseWeaponSFXSystem:
	return self._sfx_system as BaseWeaponSFXSystem


func _validate():
	assert(self._sfx_system is BaseWeaponSFXSystem)


func _custom_logic(signal_data: Dictionary[String, Variant]) -> void:
	pass


## __LOGS
# region

func pp_name() -> String:
	return "OnWeaponSFXSigASP"

func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
