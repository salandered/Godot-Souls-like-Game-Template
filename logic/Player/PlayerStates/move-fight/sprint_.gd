extends BasePlayerState


@export var sprint_stamina_cost = 20 # per sec so multiply by delta

func _ready():
	SPEED = 5.0
	TURN_SPEED = 3.2

func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(_input: InputPackage, _delta: float):
	player.move_and_slide()


func process_input_vector(input: InputPackage, delta: float):
	## same in Run, see comments there
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
		player.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED
		player.rotate_y(angle)
	# animator.set_speed_scale(player.velocity.length() / SPEED)


# sk mod
func animate():
	print_.prefix("SKM", "sprint animate with " + anim_settings + " settings_switch_time " + str(settings_switch_time))
	if animation_settings.current_animation == anim_settings:
		legs_animator.play(animation, animation_blend_time)
		torso_animator.play(animation, animation_blend_time)
	else:
		legs_animator.play(animation, 0)
		torso_animator.play(animation, 0)
	animation_settings.play(anim_settings, settings_switch_time)

# func on_exit_state():
# 	# animator.set_speed_scale(1)
