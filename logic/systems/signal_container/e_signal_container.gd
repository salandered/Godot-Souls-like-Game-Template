extends BaseCharacterSignalContainer
class_name EnemySignalContainer


func _get_character_specific_signal_data_list() -> Array[SignalData]:
	return []


## __LOG

func pp_name() -> String:
	return "EnemySignalContainer"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0