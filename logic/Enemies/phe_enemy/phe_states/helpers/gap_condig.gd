extends RefCounted
class_name GapJumpCalculator

var _strength_mult: float
var _min_coef: float
var _max_coef: float

var _curr_coef: float = 1.0

func _init(strength_mult_: float = 0.37, min_coef_: float = 0.5, max_coef_: float = 4.0) -> void:
	self._strength_mult = strength_mult_
	self._min_coef = min_coef_
	self._max_coef = max_coef_


func get_curr_coef() -> float:
	return _curr_coef


func set_coef(distance_to_player: float, is_angry: bool = false) -> float:
	var strength_ := _strength_mult
	if is_angry:
		strength_ += 0.1
	
	var raw_coef := distance_to_player * strength_
	_curr_coef = clampf(raw_coef, _min_coef, _max_coef)
	return _curr_coef


func __log_(distance_to_player, is_angry: bool):
	var strength_ := _strength_mult
	if is_angry:
		strength_ += 0.1
		
	var _msg := pp.s(
			"dist:", distance_to_player,
			"strength:", strength_,
			"raw_coef:", distance_to_player * strength_,
			"final CURR_COEF:", _curr_coef)
	return _msg