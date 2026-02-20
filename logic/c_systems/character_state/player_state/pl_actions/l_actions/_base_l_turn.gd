extends LegsAction
class_name BaseLegsTurn


var initial_rotation: Quaternion

@export var curr_turn: TurnData

var INCREASE_ROTATION: float = 1.0
var TURN_180_APEX_TIME: float


func initialise() -> void:
	if not curr_turn:
		__log_error("no curr_turn!")
		error_.warn("no curr_turn!", "BaseLegsTurn", "", WL.ASSERT)


func on_exit_action() -> void:
	__log_ext(__log_turn_exit())
	curr_turn.hard_complete()


func __log_turn_exit() -> String:
	if not __LOG_B(): return ""

	var _final_rotation := get_player().quaternion.angle_to(initial_rotation)
	var _error_angle := curr_turn.accum_rotation - curr_turn.target_angle
	return pp.s("\t accum rotation", pp.rad2deg(curr_turn.accum_rotation), " fin rotation", pp.rad2deg(_final_rotation),
		" Target:", pp.rad2deg(curr_turn.target_angle), " Error:", pp.rad2deg(_error_angle))
