extends LegsAction

var ANGULAR_SPEED: float = 10
var TARGET_SPEED: float = 5.0
var SPEED_LERP_TIME: float = 0.5 # Time to interpolate to target speed

var current_speed: float = 5.0
var lerp_timer: float = 0.0
var starting_speed: float = 5.0

func _ready():
	SPEED = 5.0
	TURN_SPEED = 3.2

func on_enter_action(input: InputPackage):
	var data = legs_sm.transfer_data.get_by_key_if_action(LS.legs_action_sprint_start, "rm_speed")
	if data and data is float:
		starting_speed = data
		current_speed = starting_speed
		lerp_timer = 0.0
	else:
		starting_speed = TARGET_SPEED
		current_speed = TARGET_SPEED
		lerp_timer = SPEED_LERP_TIME
	print_.lsm_action(action_name + " on enter", pp.ts("starting_speed", starting_speed, "current_speed", current_speed, "lerp_timer", lerp_timer))

func update(input: InputPackage, delta: float):
	if lerp_timer < SPEED_LERP_TIME:
		lerp_timer += delta
		var lerp_weight := clampf(lerp_timer / SPEED_LERP_TIME, 0.0, 1.0)
		current_speed = lerp(starting_speed, TARGET_SPEED, lerp_weight)
	else:
		current_speed = TARGET_SPEED
	
	SPEED = current_speed
	process_input_vector(input, delta)


func process_input_vector(input: InputPackage, delta: float):
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		var face_fir_rotated = face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
		player.velocity = face_fir_rotated * TURN_SPEED
		player.rotate_y(sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED
		player.rotate_y(angle)
	
	animator_manager.set_global_speed_scale(player.velocity.length() / SPEED)

func _input(event):
	if event.is_action_released("dev_speed_up"):
		SPEED += 6
	if event.is_action_released("dev_speed_down"):
		SPEED -= 6

func on_exit_action():
	animator_manager.reset_global_speed_scale()