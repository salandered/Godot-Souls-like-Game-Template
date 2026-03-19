extends RefCounted

class_name DefaultSpeedConfig


## meant to be overridden if action uses them
var SPEED: float = 2.0

## how fast the character moves forward while rotating
## usually lesser than SPEED
var TURN_SPEED: float = 1.6 # todo: consider tying to SPEED

## How fast the character rotates (changes facing direction) in rad/sec
## 0.0 disables 
## 0.5-2.0  = slow/heavy (1.5-6s for 180°) | 0.1 means 31 sec for 180
## 3.0-5.0  = normal (1-2s for 180)
## 6.0-10.0 = fast (<1s for 180)
## 15.0+    = near-instant
## E.g.: lower during attacks (1-3), higher when pursuing (3-6), very low for staggered (0.5-1.5)
## default 4.0 - 230°/s (~0.8s for 180° turn)
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
	var parts := ["sp %.2f" % SPEED]
	parts.append("turn sp %.1f" % TURN_SPEED)
	parts.append("ang sp %.1f" % ANGULAR_SPEED)
	return "Sp Conf:(%s)" % ", ".join(parts)
