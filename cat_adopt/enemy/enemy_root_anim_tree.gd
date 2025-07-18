extends AnimationTree

@onready var last_oneshot = null
@onready var anim_sm: AnimationNodeStateMachinePlayback = self["parameters/Movement/playback"]
@onready var attack_count
# todo 
@onready var enemy_base: CharacterBody3D = $'..'

func _process(_delta):
	pass


func set_movement(variant: String = "unset"):
	var current_state = enemy_base.state_machine.get_active_state().name
	var _speed: Vector2 = Vector2.ZERO
	var target_distance: float
	match current_state:
		"IdleState":
			# todo: check
			# print("IdleState near", target.global_position.distance_to(global_position))
			# print("   - target ", target.global_position)
			# print("   - NPC ", global_position)
			_speed.y = 0.0 if (enemy_base.get_target_distance() < 0.3) else 0.5
		"ReturningState":
			_speed.y = 0.0 if (enemy_base.get_target_distance() < 0.3) else 0.5
		"ChaseState":
			if variant == "Combat":
				_speed.y = 0.0
			else:
				target_distance = enemy_base.get_target_distance()
				if target_distance > 4.0:
					_speed.y = 1.0
				elif target_distance > 3.0:
					_speed.y = 0.5
				elif target_distance > 2.0:
					_speed.y = 0.5
				elif target_distance > 0:
					_speed.y = 0.0
		"DeadState":
			_speed.y = 0.0
	# print("speed: ", _speed)
	var blend = lerp(get("parameters/Movement/Movement2D/blend_position"), _speed, 0.1)
	set("parameters/Movement/Movement2D/blend_position", blend)


func _request_oneshot(oneshot: String):
	last_oneshot = oneshot
	print("parameters/" + oneshot + "/request")
	set("parameters/" + oneshot + "/request", true)

func _abort_oneshot(oneshot):
	set("parameters/" + str(oneshot) + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)


func attack():
	attack_count = randi_range(1, 2) # agent.max_attack_count)
	_request_oneshot("attack")

func retreat():
	_request_oneshot("retreat")

func hurt():
	_abort_oneshot(last_oneshot)
	_request_oneshot("hurt")


func die():
	_abort_oneshot(last_oneshot)
	anim_sm.travel("Dead")