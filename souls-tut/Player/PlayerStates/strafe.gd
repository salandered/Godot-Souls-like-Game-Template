extends BasePlayerState


var STRAFE_SPEED = 2
var STRAFE_ROTATE_SPEED = 3

func _ready():
	SPEED = 1.5
	TURN_SPEED = 1


func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func process_input_vector(input: InputPackage, delta: float) -> void:
	player.velocity = velocity_by_input(input, delta)

func update(_input: InputPackage, _delta: float):
	player.move_and_slide()
	player.look_at(player.fancy_camera.locked_target.global_position)
	player.rotate_y(PI) # some logic in velocity_by_input with locked camera makes a character be 180 reversed
