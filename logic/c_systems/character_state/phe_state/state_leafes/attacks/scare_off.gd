extends BasePHEAttack

# NOTE: bell like, start and ends with 0.5
@export var scare_off_anim_speed_curve: Curve

var anim_speed_bump := EaseCurveSampler.new()


func initialise_implementation() -> void:
	blend_time.set_specific(0.35)
	anim_speed_bump.initialise(scare_off_anim_speed_curve)
	default_sp.ANGULAR_SPEED = 0.14
	

	hit_damage = 25

var attack_weapons: Array[String] = [WeaponID.bg_aura_weapon]
func get_anim_active_weapon_ids() -> Array[String]:
	return attack_weapons

	
func on_exit_state() -> void:
	get_animator_manager().reset_global_speed_scale()
	_combat_reset()
	_pushed_rigid_bodies = false
	

# NOTE: here we test anin speed curve in real time. Very promising
func _calculate_speed_scale() -> float:
	var _anim_effective_duration := get_animator_manager().get_curr_anim_effective_duration()
	if _anim_effective_duration <= 0.0:
		return 1.0
	var _time_spent := get_animator_manager().get_curr_anim_effective_time_spent()
	# safety
	var _anim_progress := clampf(_time_spent / _anim_effective_duration, 0.0, 1.0)
	
	var _speed_scale := fvalue_angry(0.5, 0.8) + anim_speed_bump.sample_at_progress(_anim_progress)
	return _speed_scale

var _pushed_rigid_bodies: bool = false

func update(delta: float):
	var _speed_scale := _calculate_speed_scale()
	get_animator_manager().set_global_speed_scale(_speed_scale)
	
	e_movement.rotate_towards_player(delta, sp_config)
	e_movement.move_with_root(delta)

	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, fvalue_angry(2.5, 6.5), fvalue_angry(15, 90))
		me.SIG_land_wave.emit(me.global_position, AirWave2.AnimID.explode)
		_pushed_rigid_bodies = true

	_combat_update_is_attacking()
