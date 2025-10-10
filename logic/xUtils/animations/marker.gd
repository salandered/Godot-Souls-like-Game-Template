extends RefCounted
class_name Marker


var time: float
var marker_name: String

func _init(time_: float, marker_name_: String) -> void:
	time = time_
	marker_name = marker_name_

class Name:
	const START = "start"
	const END = "end"

	# specific
	const JUMP_LAUNCH = "jump_launch"
	const LOCO_LOOP_L_LEG_FULL_CONTACT = "left_leg_full_contact"
	const TURN_180_APEX = "APEX"
	const TURN_COMPLETE = "TURN_COMPLETE" # in case of turn 90 ~1.2903
	const GIVE_UP_RM = "give_up_rm"
