@tool
@icon("res://assets/x_icons/yellow/icon_visibility.png")

@abstract
class_name BaseAreaAwareness
extends Node3DCharacterSystem


@export var extreme_landing_height: float = 1.1
@export var landing_height: float = 0.6
@export var tolerated_height: float = 0.2

@onready var downcast: DownCast = %Downcast

var _character: BaseCharacter


func __hard_dependencies() -> Array:
	return [
		downcast,
		_character
	]


func initialize(character_: BaseCharacter):
	_character = character_


	__perform_validation()

	initialize_implementation()


func initialize_implementation():
	pass


func _get_character() -> BaseCharacter:
	return _character


## calls the built-in in CharacterBody3D.is_on_floor()
func is_on_floor() -> bool:
	return _character.is_on_floor()


## "not is_on_floor() but close"
func is_almost_on_floor(__log: bool = false) -> bool:
	return floor_dist_under_tolerated_height(__log)


func floor_dist_under_tolerated_height(__log: bool = false) -> bool:
	var _r := get_floor_distance() <= tolerated_height
	if __log: __log_floor_dist("<= tolerate height", tolerated_height, "? =>", _r)
	return _r


func floor_dist_under_extreme_landing_height(__log: bool = false) -> bool:
	var _r := get_floor_distance() <= extreme_landing_height
	if __log: __log_floor_dist("<= land height", extreme_landing_height, "? =>", _r)
	return _r


func floor_dist_under_landing_height(__log: bool = false) -> bool:
	var _r := get_floor_distance() <= landing_height
	if __log: __log_floor_dist("<= land height", landing_height, "? =>", _r)
	return _r


func get_floor_distance() -> float:
	if not __validation_ok():
		return Const.BIG_MEANINGLESS_NUMBER
	if downcast.is_colliding():
		#__log_('-------------- colliding')
		return downcast.global_position.distance_to(downcast.get_collision_point())
	#__log_aware('-------------- not colliding')
	return Const.BIG_MEANINGLESS_NUMBER


# region: LOG


func __LOG_B() -> bool:
	return LogToggler.AWARENESS_B


func __log_floor_dist(...parts: Array):
	__log_("floor dist", get_floor_distance(), pp.list_(parts), "exact value", str(get_floor_distance()))

# endregion
