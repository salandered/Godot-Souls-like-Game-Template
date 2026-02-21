extends BaseCharacterSignalContainer
class_name PlayerSignalContainer


signal SFX_switch_weapon(payload: Dictionary[StringName, Variant])

func _get_character_specific_signal_data_list() -> Array[SignalData]:
	return [
		SignalData.new(SignalID.sfx_switch_weapon, SFX_switch_weapon)
	]


## __LOG


func __LOG_INDENT() -> int:
	return 0