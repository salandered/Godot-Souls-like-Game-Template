extends LimboState

@onready var player_skin: PlayerSkin = %PlayerSkin


const STARTED_FALL := &"STARTED_FALL"
const GOT_ON_FLOOR := &"GOT_ON_FLOOR"


func _enter() -> void:
	print(">> entered ", name)
	agent.velocity.y = agent.jump_velocity
	player_skin.jump()

func _update(_delta: float) -> void:
	agent.velocity.y -= agent.gravity * _delta
	agent.velocity.y = maxf(agent.velocity.y, -agent.max_fall_speed)

	agent.move_and_slide()

	if agent.is_on_floor():
		get_root().dispatch(GOT_ON_FLOOR)

	if not agent.is_on_floor() and agent.velocity.y < 0:
		# TODO: start fall later. at least jump anim should end
		get_root().dispatch(STARTED_FALL)

	# TODO: debug mode
	if Input.is_action_just_pressed("jump"):
		agent.velocity.y = agent.jump_velocity
		player_skin.jump()
