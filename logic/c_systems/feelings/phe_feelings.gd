@tool
extends BaseFeelings
class_name PHEFeelings


@export var MAX_HEALTH = 200
@export var PHASE_SWITCH_HP_TRESHOLD: float = 0.6

func is_player() -> bool:
	return false


func initialise():
	pass


func get_max_health() -> float:
	return MAX_HEALTH


func is_lower_to_switch_phase() -> bool:
	var _r := get_curr_health() <= get_max_health() * PHASE_SWITCH_HP_TRESHOLD
	return _r

func is_lower_just_before_switch_phase() -> bool:
	var _r := get_curr_health() < get_max_health() * (PHASE_SWITCH_HP_TRESHOLD + 0.1)
	return _r


func __LOG_B() -> bool:
	return LogToggler.FEEL_B