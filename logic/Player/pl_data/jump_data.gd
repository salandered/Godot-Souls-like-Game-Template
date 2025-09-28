extends Resource
class_name UsualJumpData


# Animation Timeline:
# [---------- jump_start animation ----------]
# 	 ↑                    ↑               ↑
#    0.0s            LAUNCH_TIMING    Animation End
# 					(feet leave)     (transition)
					
# Physics Timeline (starts at LAUNCH_TIMING):
# 						 [---- time_to_peak ----][--- time_to_descent ---]
# 							  ↑                        ↑
# 							Peak                   Back to ground
# 						  (in midair)              (in midair/landing)

var jump_height := 3 # meters
var time_to_peak := 1
var time_to_descent := 1

var jump_speed: float
var jump_up_gravity: float
var jump_fall_gravity: float

static func calculate_jump_speed(height: float, time_to_peak_: float) -> float:
	return (2.0 * height) / time_to_peak_

static func calculate_jump_gravity(height: float, time_to_peak_: float) -> float:
	return (2.0 * height) / pow(time_to_peak_, 2.0)

static func calculate_fall_gravity(height: float, time_to_descent_: float) -> float:
	return (2.0 * height) / pow(time_to_descent_, 2.0)


func _init():
	jump_speed = calculate_jump_speed(jump_height, time_to_peak)
	jump_up_gravity = calculate_jump_gravity(jump_height, time_to_peak)
	jump_fall_gravity = calculate_fall_gravity(jump_height, time_to_descent)

func _to_string() -> String:
	return pp.ts(
		"jump_speed", jump_speed,
		"up_gravity", jump_up_gravity,
		"fall_gravity", jump_fall_gravity,
		)
