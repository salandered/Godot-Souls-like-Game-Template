extends LimboState

@onready var player_skin: PlayerSkin = %PlayerSkin


const INPUT_MOVED := &"INPUT_MOVED"
const STARTED_FALL := &"STARTED_FALL"


func _enter() -> void:
	print(">> entered Idle")
	print(player_skin)
	player_skin.idle()


func _update(_delta: float) -> void:
	agent.velocity.y -= agent.gravity * _delta
	agent.velocity.y = maxf(agent.velocity.y, -agent.max_fall_speed)
	
	agent.move_and_slide()

	if agent.input_move_coming():
		get_root().dispatch(INPUT_MOVED)

	if not agent.is_on_floor() and agent.velocity.y < 0:
		get_root().dispatch(STARTED_FALL)
