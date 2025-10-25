extends RefCounted
class_name TurnData

var target_angle: float
var turn_direction: String
var accum_rotation: float
var turn_completed: bool

const TURN_DIR_RIGHT := "right"
const TURN_DIR_LEFT := "left"

const TARGET_ANGLE_DICT := "target_angle"
const TURN_DIRECTION_DICT := "turn_direction"
const ACCUM_ROTATION_DICT := "accum_rotation"
const TURN_COMPLETED_DICT := "turn_completed"

## idempotent
func initialise(angle: float, turn_direction_: String):
	target_angle = angle
	turn_direction = turn_direction_
	accum_rotation = 0.0
	turn_completed = false
	__validate()

func update(turn_completed_: bool, accum_rotation_: float, ):
	turn_completed = turn_completed_
	accum_rotation = accum_rotation_

func initialise_from_dict(data: Dictionary):
	target_angle = data.get(TARGET_ANGLE_DICT, 0.0)
	accum_rotation = data.get(ACCUM_ROTATION_DICT, 0.0)
	turn_completed = data.get(TURN_COMPLETED_DICT, false)
	turn_direction = data.get(TURN_DIRECTION_DICT, "")
	__validate()

func is_turn_dir_right() -> bool:
	return turn_direction == TURN_DIR_RIGHT


func hard_complete():
	turn_completed = true

func _to_string() -> String:
	return "Target ∠ %s, AccRot %s, Completed %s, Dir %s" % \
		[pp.rad2deg(target_angle), pp.rad2deg(accum_rotation), str(turn_completed), turn_direction]

func to_dict() -> Dictionary:
	return {
		TARGET_ANGLE_DICT: target_angle,
		ACCUM_ROTATION_DICT: accum_rotation,
		TURN_COMPLETED_DICT: turn_completed,
		TURN_DIRECTION_DICT: turn_direction,
	}

func __validate():
	if not turn_direction in [TURN_DIR_RIGHT, TURN_DIR_LEFT]:
		print_.warn("Will be set to TURN_DIR_RIGHT. Not turn_direction in [TURN_DIR_RIGHT, TURN_DIR_LEFT]: " + turn_direction)
		turn_direction = TURN_DIR_RIGHT