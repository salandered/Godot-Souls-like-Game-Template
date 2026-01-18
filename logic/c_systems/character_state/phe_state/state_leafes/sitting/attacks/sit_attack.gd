extends BasePHEAttack


var _pushed_rigid_bodies: bool = false


var attack_weapons: Array[String] = [WeaponID.bg_aura_weapon]
func get_anim_active_weapon_ids() -> Array[String]:
	return attack_weapons


func initialise_implementation() -> void:
	blend_time.set_specific(0.35)
	hit_damage = 40.0
	default_attack_weapons = [WeaponID.bg_aura_weapon]


func on_exit_state() -> void:
	get_animator_manager().reset_global_speed_scale()
	_combat_reset()
	_pushed_rigid_bodies = false
	

func update(delta: float):
	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, fvalue_angry(2.5, 6.5), fvalue_angry(15, 90))
		me.SIG_land_wave.emit(me.global_position, AirWave2.AnimID.explode)
		_pushed_rigid_bodies = true

	_combat_update_is_attacking()
