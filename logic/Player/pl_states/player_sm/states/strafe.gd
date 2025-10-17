extends PlayerState


var STRAFE_SPEED = 2
var STRAFE_ROTATE_SPEED = 3

func _ready():
	SPEED = 1.5
	TURN_SPEED = 1


func check_transition(input: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		PLVerdict.new("midair")
	
	return best_next_state_from_input(input)


# func process_input_vector(input: InputPackage, delta: float) -> void:
# 	player.velocity = velocity_by_input(input, delta)

# func update(_input: InputPackage, _delta: float):
# 	var target_pos = player.fancy_camera.locked_target.global_position
# 	target_pos.y = player.global_position.y
# 	u.safe_look_at(player, target_pos)
# 	player.rotate_y(PI) # some logic in velocity_by_input with locked camera makes a character be 180 reversed

	# # Decide animation based on movement input
	# if abs(_input.forward_input) < 0.1 and abs(_input.orbit_input) < 0.1:
	# 	change_animation_to(A.strafe_idle)

	# elif abs(_input.orbit_input) > abs(_input.forward_input):
	# 	if _input.orbit_input > 0.0:
	# 		change_animation_to(A.strafe_R)
	# 	else:
	# 		change_animation_to(A.strafe_L)
	# else:
	# 	if _input.forward_input > 0.0:
	# 		change_animation_to(A.strafe_forward)
	# 	else:
	# 		change_animation_to(A.strafe_back)
