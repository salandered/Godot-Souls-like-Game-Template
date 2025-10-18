extends RefCounted

class_name DefaultSpeedConfig


## meant to be overriden if action uses them
var SPEED: float = 2.0
## how fast the character moves forward while rotating
## usually lesser than SPEED
var TURN_SPEED: float = 1.6 # todo: consider tying to SPEED
## how fast the character rotates (changes facing direction)
## 4 means ~ 230. max a player can turn in one frame is ANGULAR_SPEED * delta == 4.0 * 0.0167 = ~ 3.8 degrees.
var ANGULAR_SPEED: float = 4.0


func _init(
	SPEED_: float = 2.0,
	TURN_SPEED_: float = 1.6,
	ANGULAR_SPEED_: float = 4.0
) -> void:
	SPEED = SPEED_
	TURN_SPEED = TURN_SPEED_
	ANGULAR_SPEED = ANGULAR_SPEED_


func _to_string() -> String:
	var parts = ["sp %.2f" % SPEED]
	parts.append("turn sp %.1f" % TURN_SPEED)
	parts.append("ang sp %.1f" % ANGULAR_SPEED)
	return "Sp Conf:(%s)" % ", ".join(parts)
