extends RefCounted
class_name Marker

## DOCS
# Animation Markers are persistent - they're part of the Animation resource structure.
# 
# For native Godot animations (.res): Markers save automatically.
# 
# For imported animations (GLB/FBX): Enable "Save to File" in Advanced Import Settings
# to create a separate .res file, otherwise markers will be lost on reimport! WARNING
# 
# Note: Markers are NOT "custom tracks" - they're timeline metadata.
# The "Keep Custom Tracks" setting only applies to actual anim tracks.


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

	# strongly recommended in any loco loop anim 
	const LOCO_LOOP_L_LEG_FULL_CONTACT = "left_leg_full_contact"
	const TURN_180_APEX = "APEX"
	const TURN_COMPLETE = "TURN_COMPLETE"
	const GIVE_UP_RM = "give_up_rm"
	
	# strongly recommended in attack states for player
	# good to check for enemy attack states 
	const ALLOWS_SWITCH = "allows_switch"
	const ALLOWS_SWITCH_TO_ITSELF = "allows_switch_to_itself" # used in basic attack
	
	# for now in enemy for specific series logic
	const EARLY_SERIES_SWITCH = "EARLY_SERIES_SWITCH"
	
	# to mimick that animation is from run (not idle pose) (e.g. dodge)
	const FROM_RUN = "from_run"
	const TO_RUN = "to_run"
	const TO_IDLE = "to_idle"

	# HSM anim 

	# overlay
	const OVERLAY_START = "overlay_start"
	const OVERLAY_END = "overlay_end"
