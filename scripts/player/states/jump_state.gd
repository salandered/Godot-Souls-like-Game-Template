extends LimboState

@onready var player_skin: PlayerSkin = %PlayerSkin
@onready var animation_player: AnimationPlayer = %AnimationPlayer

const STARTED_FALL := &"STARTED_FALL"
const GOT_ON_FLOOR := &"GOT_ON_FLOOR"
const GOT_ON_FLOOR_MOVING := &"GOT_ON_FLOOR_MOVING"

var anim_length_almost := 0.8 # TODO oh
var anim_length := 1.2 # TODO oh
var jump_anim_almost_finished := false
var jump_anim_finished := false

func _enter() -> void:
	print(">> entered ", name)
	player_skin.jump()
	jump_anim_almost_finished = false
	jump_anim_finished = false
	get_tree().create_timer(anim_length).timeout.connect(func():
			jump_anim_finished = true
			print("jump_anim_finished to true")
	)
	get_tree().create_timer(anim_length_almost).timeout.connect(func():
			jump_anim_almost_finished = true
			print("jump_anim_almost_finished to true")
	)
	await get_tree().create_timer(.4).timeout # for the windup
	agent.velocity.y = agent.jump_velocity

func _update(_delta: float) -> void:
	var player := agent

	# if jump_anim_almost_finished:
	agent.velocity.y -= agent.gravity * _delta
	agent.velocity.y = maxf(agent.velocity.y, -agent.max_fall_speed)

	if player.input_move_coming():
		var move_direction: Vector3 = player.input_move_direction()
		player.accelerate(move_direction, _delta)
	else:
		player.deccelerate(_delta)

	agent.move_and_slide()

	if jump_anim_finished:
		if not agent.is_on_floor() and agent.velocity.y < 0:
			# TODO: start fall later. at least jump anim should end
			print(STARTED_FALL)
			get_root().dispatch(STARTED_FALL)

	if jump_anim_almost_finished:
		if agent.input_move_coming() and agent.is_on_floor():
			print(GOT_ON_FLOOR_MOVING)
			get_root().dispatch(GOT_ON_FLOOR_MOVING)

	if jump_anim_almost_finished:
		if not agent.input_move_coming() and agent.is_on_floor():
			print(GOT_ON_FLOOR)
			get_root().dispatch(GOT_ON_FLOOR)

	# TODO: debug mode for infinite jump
	if Input.is_action_just_pressed("jump"):
		print("debug: jump jump ")
		agent.velocity.y = 10
		player_skin.jump()
