extends RefCounted
class_name MarkerName

## deprecated i guess
const START = "start"
const END = "end"

## jump
const JUMP_LAUNCH = "jump_launch"
const JUMP_START_END = "jump_start_end"
const LAND_START = "land_start"
const LEG_CONTACT = "leg_contact"
const RUN_AGAIN = "run_again"
const PEAK = "PEAK"

## some loco
# NOTE: set in any loco loop anim 
const LOCO_LOOP_L_LEG_FULL_CONTACT = "left_leg_full_contact"
#
const TURN_180_APEX = "APEX"
const TURN_COMPLETE = "TURN_COMPLETE"
const GIVE_UP_RM = "give_up_rm"


## switching
# NOTE: set in attack states for player
# also good to check for enemy attack states 
const ALLOWS_SWITCH = "allows_switch"
# currently used in basic pl attack
const ALLOWS_SWITCH_TO_ITSELF = "allows_switch_to_itself"
#
const ALLOWS_SWITCH_TO_ATTACK = "ALLOWS_SWITCH_TO_ATTACK"
# in enemy for specific series logic
const EARLY_SERIES_SWITCH = "EARLY_SERIES_SWITCH"

# to mimick that animation is from run (not idle pose) (e.g. dodge)
const FROM_RUN = "from_run"
#
const FROM_IDLE = "FROM_IDLE"
#
const TO_RUN = "to_run"
#
const TO_IDLE = "to_idle"
const FROM_DODGE = "FROM_DODGE"

# enemy death
const DEATH_SCATTER = "death_scatter"

## fall/stand-up
const HALF_STAND_UP = "HALF_STAND_UP"
const STAND_UP_GLUE = "STAND_UP_GLUE"

## overlay anim (usually reaction)
const OVERLAY_START = "overlay_start"
const OVERLAY_END = "overlay_end"
