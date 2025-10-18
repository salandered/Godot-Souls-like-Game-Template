extends RefCounted

class_name SpeedConfig


var _default_sp_config: DefaultSpeedConfig
var _speed_mult: float
var _speed: float
var _angular_sp: float
var _turn_speed: float


func _init(
	default_sp_config_: DefaultSpeedConfig = null,
	speed_multiplier_: float = 1.0,
	override_speed_: float = -1.0,
	override_angular_sp_: float = -1.0,
	override_turn_speed_: float = -1.0
) -> void:
	if default_sp_config_ == null:
		self._default_sp_config = DefaultSpeedConfig.new()
	else:
		self._default_sp_config = default_sp_config_
	self._speed_mult = speed_multiplier_
	self._speed = override_speed_
	self._angular_sp = override_angular_sp_
	self._turn_speed = override_turn_speed_


func tie_turn_sp_to_speed(multiplier: float):
	if _speed == -1:
		print_.warn("cant use _speed that is not set. Will remain as it was: " + str(_turn_speed))
		return
	_turn_speed = _speed * multiplier


func get_speed_multiplier() -> float:
	return _speed_mult


func get_speed() -> float:
	if _speed != -1.0:
		return _speed
	return _default_sp_config.SPEED


func get_angular_sp() -> float:
	if _angular_sp != -1.0:
		return _angular_sp
	return _default_sp_config.ANGULAR_SPEED


func get_turn_speed() -> float:
	if _turn_speed != -1.0:
		return _turn_speed
	return _default_sp_config.TURN_SPEED


func _to_string() -> String:
	var parts = ["sp mult %.2f" % _speed_mult]
	if _speed != -1.0: parts.append("sp %.1f" % _speed)
	if _angular_sp != -1.0: parts.append("ang sp %.1f" % _angular_sp)
	if _turn_speed != -1.0: parts.append("turn sp %.1f" % _turn_speed)
	return "Sp Conf:(%s)" % ", ".join(parts)