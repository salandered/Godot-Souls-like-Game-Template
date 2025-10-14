extends RefCounted

class_name SpeedConfig

var speed_multiplier: float
var override_speed: float
var override_angular_sp: float
var override_turn_speed: float

func _init(
	speed_multiplier_: float = 1.0,
	override_speed_: float = -1.0,
	override_angular_sp_: float = -1.0,
	override_turn_speed_: float = -1.0
) -> void:
	speed_multiplier = speed_multiplier_
	override_speed = override_speed_
	override_angular_sp = override_angular_sp_
	override_turn_speed = override_turn_speed_

func tie_turn_sp_to_speed(multiplier: float):
	if override_speed == -1:
		print_.warn("cant use override_speed that is not set. Will remain as it was: " + str(override_turn_speed))
		return
	override_turn_speed = override_speed * multiplier

func get_override_speed(default: float) -> float:
	if override_speed != -1.0:
		return override_speed
	return default

func get_override_angular_sp(default: float) -> float:
	if override_angular_sp != -1.0:
		return override_angular_sp
	return default

func get_override_turn_speed(default: float) -> float:
	if override_turn_speed != -1.0:
		return override_turn_speed
	return default

func _to_string() -> String:
	var parts = ["sp mult %.2f" % speed_multiplier]
	if override_speed != -1.0: parts.append("sp %.1f" % override_speed)
	if override_angular_sp != -1.0: parts.append("ang sp %.1f" % override_angular_sp)
	if override_turn_speed != -1.0: parts.append("turn sp %.1f" % override_turn_speed)
	return "Sp Conf:(%s)" % ",".join(parts)