extends LimboState

@onready var player_skin: PlayerSkin = %PlayerSkin

const WENT_IDLE := &"WENT_IDLE"
const INPUT_JUMPED := &"INPUT_JUMPED"
const STARTED_FALL := &"STARTED_FALL"
const INPUT_ATTACK := &"INPUT_ATTACK"


func _enter() -> void:
	print(">> entered ", name)
	player_skin.set_moving()

func _update(_delta: float) -> void:
	var player := agent

	var move_direction: Vector3 = player.input_move_direction()
	
	# ANIMATION
	var xz_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	player_skin.set_moving_speed(inverse_lerp(player.max_speed_walk, player.max_speed_run / 2, xz_velocity.length()))
	
	# MOVE SPEED
	if player.input_move_coming():
		player.accelerate(move_direction, _delta)
	else:
		player.deccelerate(_delta)

	player.velocity.y -= player.gravity * _delta

	player.move_and_slide()

	if xz_velocity.length() < player.stopping_speed:
		get_root().dispatch(WENT_IDLE)

	if Input.is_action_just_pressed("jump"):
		print("J")
		get_root().dispatch(INPUT_JUMPED)

	if not player.is_on_floor() and player.velocity.y < 0:
		get_root().dispatch(STARTED_FALL)

	player_skin.handle_action(false)
		# get_root().dispatch(INPUT_ATTACK)
