class_name MarkerName
extends RefCounted


class JUMP:
	const LAUNCH = "jump_launch"
	const START_END = "jump_start_end"
	const LAND_START = "land_start"
	const LEG_CONTACT = "leg_contact"
	const RUN_AGAIN = "run_again"
	const PEAK = "PEAK"

## some loco
# NOTE: set in any loco loop anim 
const LOCO_LOOP_L_LEG_FULL_CONTACT = "left_leg_full_contact"
#
const TURN_180_APEX = "APEX"
# const TURN_COMPLETE = "TURN_COMPLETE"
# const GIVE_UP_RM = "give_up_rm"


## switching
# NOTE: set in attack states for player
# also good to check for enemy attack states 
const ALLOWS_SWITCH = "allows_switch"
# currently used in basic pl attack
const ALLOWS_SWITCH_TO_ITSELF = "allows_switch_to_itself"
#
const ALLOWS_SWITCH_TO_ATTACK = "allows_switch_to_attack"
# in enemy for specific series logic
const EARLY_SERIES_SWITCH = "early_series_switch"

# to mimick that animation is from run (not idle pose) (e.g. dodge)
const FROM_RUN = "from_run"
#
const FROM_IDLE = "FROM_IDLE"
#
const TO_RUN = "to_run"
#
const TO_IDLE = "to_idle"
const FROM_DODGE = "from_dodge"

# enemy death
const DEATH_SCATTER = "death_scatter"

# 
const PUSH_ITEMS_AROUND = "push_items_around"


## fall/stand-up
# const HALF_STAND_UP = "half_stand_up"
# const STAND_UP_GLUE = "stand_up_glue"

## overlay anim (usually reaction)
class OVERLAY:
	const START = "overlay_start"
	const END = "overlay_end"
