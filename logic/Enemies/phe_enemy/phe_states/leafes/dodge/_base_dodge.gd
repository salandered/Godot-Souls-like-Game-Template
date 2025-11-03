extends BasePHELeaf
class_name BasePHEDodgeLeaf


var sp_config: SpeedConfig

var SCALE_LENGTH := 1.0


## DOCS:
##   DANGER: implementation must not use initialise, but initialise_implementation()


func initialise() -> void:
	TIME_REMAINING_TO_END = 0.2
	default_sp.ANGULAR_SPEED = 2
	sp_config = SpeedConfig.new(default_sp)
	var from_run := anim.get_marker_time_by_name(Marker.Name_.FROM_RUN, 0.1)

	start_time_offset.set_by_prev_action({
		PHES.Leaf.pursue: from_run,
		PHES.Leaf.dodge_B: from_run,
		PHES.Leaf.dodge_F: from_run,
		PHES.Leaf.dodge_R: from_run,
		PHES.Leaf.dodge_L: from_run,
	})

	initialise_implementation()


# to override instead of initialise
func initialise_implementation():
	pass


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config)
	e_movement.move_with_root(delta, SCALE_LENGTH)
