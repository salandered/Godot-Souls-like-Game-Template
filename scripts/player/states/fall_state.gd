extends LimboState

@onready var player_skin: PlayerSkin = %PlayerSkin


const GOT_ON_FLOOR := &"GOT_ON_FLOOR"


func _enter() -> void:
	print(">> entered ", name)
	player_skin.fall()

func _update(_delta: float) -> void:
	
	agent.velocity.y -= agent.gravity * _delta
	agent.velocity.y = maxf(agent.velocity.y, -agent.max_fall_speed)


	agent.move_and_slide()

	if agent.is_on_floor():
		get_root().dispatch(GOT_ON_FLOOR)

	# TODO: debug mode
	if Input.is_action_just_pressed("jump"):
		agent.velocity.y = agent.jump_velocity
		player_skin.jump()
