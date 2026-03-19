@abstract
class_name BaseFeelings
extends NodeCharacterSystem

var statuses: Dictionary[String, bool] # todo: system

var __god_mode: bool = false

var _current_health: float


func _ready() -> void:
	_current_health = get_max_health()
	__log_("health", "curr health initted with max health", _current_health, get_max_health())
	statuses = {}

	initialize()


@abstract func initialize()


@abstract func get_max_health() -> float


func add_health(amount: float):
	_change_health(amount)

func lose_health(amount: float):
	_change_health(-amount)


func is_zero_health() -> bool:
	return _current_health <= 0.0


func get_curr_health() -> float:
	return _current_health


func _change_health(amount: float) -> void:
	if amount == 0.0: return
	if __god_mode:
		if abs(amount) > 1: __log_("health", pp.s("not changed: god mode"))
		return

	var _new_health := _current_health + amount
	_current_health = clampf(_new_health, 0, get_max_health())
	
	# TODO if _current_health <= 0.0:
	
	if abs(amount) > 1: __log_("health", pp.s("changed", amount))


func check_status(status_name: String) -> bool:
	if status_name in statuses:
		return statuses[status_name]
	else:
		__log_error("no status in statuses", "check_status", "return false", pp.in_q(status_name), pp.in_q(statuses))
		return false


func __set_specific_health(amount: float):
	if eu.is_release():
		return
	_current_health = amount


func __LOG_INDENT() -> int:
	return LogToggler.FEEL_INDENT