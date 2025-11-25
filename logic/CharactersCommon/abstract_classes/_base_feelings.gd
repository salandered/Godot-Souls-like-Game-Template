@tool
@icon("res://-assets-/x_icons/white/icon_heart.png")

@abstract
class_name BaseFeelings
extends Node

var statuses: Dictionary # todo: system

var __god_mode: bool = false

var _current_health: float


## DOCS: 
##  WARNING don't use _ready in implementations, use initialise()
##  

func _ready() -> void:
	_current_health = get_max_health()
	__log_("health", "curr health initted with max health", _current_health, get_max_health())
	statuses = {}
	initialise()


@abstract func initialise()


@abstract func is_player() -> bool


@abstract func get_max_health() -> float


func add_health(amount: float):
	_change_health(amount)

func lose_health(amount: float):
	_change_health(-amount)


## dev usage only
func _set_specific_health(amount: float):
	_current_health = amount


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
		__log_warn("no status in statuses", "check_status", "return false", pp.in_q(status_name), pp.in_q(statuses))
		return false


# region __LOGS

func __log_(_prefix: String, ...parts: Array):
	print_.feel(is_player(), _prefix, pp.list_(parts))

func __log_warn(what: String, where: String, fallback: String, ...context: Array):
	print_.warn(false, what, where, fallback, is_player(), pp.list_(context))


# endregion
