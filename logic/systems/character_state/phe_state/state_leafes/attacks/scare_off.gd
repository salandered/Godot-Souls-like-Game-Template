extends BasePHEAttack

# NOTE: bell like, start and ends with 0.5
@export var scare_off_anim_speed_curve: Curve

var anim_speed_bump := EaseCurveSampler.new()


func get_active_weapon_name() -> String:
	return WeaponID.bg_aura_weapon


func initialise_implementation() -> void:
	blend_time.set_specific(0.35)
	anim_speed_bump.initialise(scare_off_anim_speed_curve)
	default_sp.ANGULAR_SPEED = 0.14
	

	hit_damage = 25

func get_active_weapon_names() -> Array[String]:
	return [WeaponID.bg_aura_weapon]

func on_exit_state() -> void:
	get_animator_manager().reset_global_speed_scale()
	_combat_reset_all_weapons()
	_pushed_rigid_bodies = false
	

# NOTE: here we test anin speed curve in real time. Very promising
func _calculate_speed_scale() -> float:
	var _anim_effective_duration := get_animator_manager().get_curr_anim_effective_duration()
	if _anim_effective_duration <= 0.0:
		return 1.0
	var _time_spent := get_animator_manager().get_curr_anim_effective_time_spent()
	# safety
	var _anim_progress := clampf(_time_spent / _anim_effective_duration, 0.0, 1.0)
	
	var _speed_scale := 0.5 + anim_speed_bump.sample_at_progress(_anim_progress)
	return _speed_scale

var _pushed_rigid_bodies: bool = false

func update(delta: float):
	var _speed_scale := _calculate_speed_scale()
	get_animator_manager().set_global_speed_scale(_speed_scale)
	
	e_movement.rotate_towards_player(delta, sp_config)
	e_movement.move_with_root(delta)

	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, fvalue_angry(2, 3.5), fvalue_angry(10, 80))
		_pushed_rigid_bodies = true

	_combat_update_is_attacking()
