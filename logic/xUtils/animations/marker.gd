extends RefCounted
class_name Marker


var time: float
var marker_name: String


func _init(time_: float, marker_name_: String) -> void:
	time = time_
	marker_name = marker_name_


class Name_:
	const START = "start"
	const END = "end"

	# jump
	
	const JUMP_LAUNCH = "jump_launch"
	const JUMP_START_END = "jump_start_end"
	const LAND_START = "land_start"
	const LEG_CONTACT = "leg_contact"
	const RUN_AGAIN = "run_again"
	const PEAK = "PEAK"


	const LOCO_LOOP_L_LEG_FULL_CONTACT = "left_leg_full_contact"
	const TURN_180_APEX = "APEX"
	const TURN_COMPLETE = "TURN_COMPLETE"
	const GIVE_UP_RM = "give_up_rm"
	
	# strongly recommended in attack states
	const ALLOWS_SWITCH = "allows_switch"
	
	# to mimick from run anims (e.g. dodge)
	const FROM_RUN = "from_run"
	const TO_RUN = "to_run"
	const TO_IDLE = "to_idle"


	# HSM anim 
	const COMMIT = "commit"


	# overlay
	const OVERLAY_START = "overlay_start"
	const OVERLAY_END = "overlay_end"
