class_name EnemySignalContainer
extends BaseCharacterSignalContainer


signal SFX_jingles(payload: Dictionary[StringName, Variant])


func _get_character_specific_signal_data_list() -> Array[SignalData]:
	return [
		SignalData.new(SignalID.sfx_jingles, SFX_jingles)
		]


## __LOG


func __LOG_INDENT() -> int:
	return 0
