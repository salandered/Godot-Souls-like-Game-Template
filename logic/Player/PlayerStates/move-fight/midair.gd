extends BasePlayerState


# todo


@export var DELTA_VECTOR_LENGTH = 0.1
var jump_direction: Vector3

var landing_height: float = 1.163


func default_lifecycle(_input: InputPackage):
	var floor_distance := area_awareness.get_floor_distance()
	if floor_distance < landing_height:
		var xz_velocity = player.velocity
		xz_velocity.y = 0
		if xz_velocity.length_squared() >= 10:
			return "landing_sprint"
		return "landing_run"
	else:
		# still falling
		return "okay"


func update(_input: InputPackage, _delta):
	player.velocity.y -= gravity * _delta
	player.move_and_slide()

## Divide velocity and look direction
func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var input_delta_vector = input_direction * DELTA_VECTOR_LENGTH
	
	# ep 6: (jump_direction + input_delta_vector * delta).limit_length(clamp(player.velocity.length(), 1, 999999))
	jump_direction = (jump_direction + input_delta_vector).limit_length(player.velocity.length())
	u.safe_look_at(player, player.global_position - jump_direction)

	# ep 6: (player.velocity + input_delta_vector * delta).limit_length(player.velocity.length())
	var new_velocity = (player.velocity + input_delta_vector).limit_length(player.velocity.length())
	player.velocity = new_velocity

func on_enter_state():
		# the clamp construction is here to 
		# 1) prevent look_at annoying errors when our velocity is zero and it can't look_at properly
		# 3) have a way to scale from velocity. The longer the vector is, the harder it is to modify it by adding a delta.
		#    Scaling jump_direction with velocity is giving us that natural behaviour of faster jumps (sprints)
		#    being less controllable, and jumps from standing position being more volatile.
		#    The dependance on velocity paramter is not critical, delete this if you don't like the approach.
	jump_direction = Vector3(player.basis.z) * clamp(player.velocity.length(), 1, 999999)
	jump_direction.y = 0
