extends BasePHEAttack

var decel_speed: float = 20
# NOTE: bell like, start and ends with 0.5
@export var scare_off_anim_speed_curve: Curve

var anim_speed_bump := EaseCurveSampler.new()

func initialise() -> void:
	blend_time.set_specific(0.4)
	anim_speed_bump.initialise(scare_off_anim_speed_curve)


func on_exit_state():
	get_animator_manager().reset_global_speed_scale()

	
func _calculate_speed_scale() -> float:
	var _anim_duration = get_animator_manager().get_curr_anim().duration
	if _anim_duration <= 0.0:
		return 1.0
	var _anim_progress = get_animator_manager().get_current_anim_effective_time_spent() / _anim_duration
	var _speed_scale = 0.5 + anim_speed_bump.sample_at_progress(_anim_progress)
	return _speed_scale
		

func update(delta):
	var _speed_scale = _calculate_speed_scale()
	get_animator_manager().set_global_speed_scale(_speed_scale)
	
	# e_movement.rotate_towards_player(delta, sp_config, angle_adjustment)
	e_movement.move_with_root(delta)
	manage_weapons()


# func smooth_stop(delta):
# 	var horizontal_vel = Vector3(me.velocity.x, 0, me.velocity.z)
	
# 	horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, decel_speed * delta)
	
# 	me.velocity.x = horizontal_vel.x
# 	me.velocity.z = horizontal_vel.z