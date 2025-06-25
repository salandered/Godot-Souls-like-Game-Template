extends LimboState

@onready var player_skin: Node3D = %PlayerSkin

const WENT_IDLE := &"WENT_IDLE"
const INPUT_JUMPED := &"INPUT_JUMPED"
const STARTED_FALL := &"STARTED_FALL"



func _enter() -> void:
	print(">> entered Move")
	player_skin.set_moving()

func _update(_delta: float) -> void:
	var player := agent

	var move_direction: Vector3 = player.input_move_direction()
	
	# ANIMATION
	var xz_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	player_skin.set_moving_speed(inverse_lerp(0.0, player.max_speed_sprint / 2, xz_velocity.length()))
	
	# MOVE SPEED
	if player.input_move_coming():
		player.accelerate(move_direction, _delta)
	else:
		_deccelerate(_delta)
	
	player.velocity.y -= player.gravity * _delta

	player.move_and_slide()

	if xz_velocity.length() < player.stopping_speed:
		get_root().dispatch(WENT_IDLE)

	if Input.is_action_just_pressed("jump"):
		get_root().dispatch(INPUT_JUMPED)

	if not player.is_on_floor() and player.velocity.y < 0:
		get_root().dispatch(STARTED_FALL)




func _deccelerate(_delta):
	var velocity_ground_plane := Vector3(agent.velocity.x, 0.0, agent.velocity.z)
	# moves towards zero
	velocity_ground_plane = velocity_ground_plane.move_toward(
		Vector3.ZERO,
		agent.deceleration * _delta
	)
	agent.velocity.x = velocity_ground_plane.x
	agent.velocity.z = velocity_ground_plane.z
