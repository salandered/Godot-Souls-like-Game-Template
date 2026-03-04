extends BasePHEAttack


var DECEL_SPEED: float = 11


## attack state as well (used to be neutral)

func initialize_implementation() -> void:
	default_sp.ANGULAR_SPEED = 0.1


var attack_weapons: Array[StringName] = [WeaponID.bg_aura_weapon]
func get_anim_active_weapon_ids() -> Array[StringName]:
	return attack_weapons


var _pushed_rigid_bodies: bool = false

func on_enter_state() -> void:
	_combat_set_hit_data()
	
	SigUtils.safe_emit_sig_data(
		me.get_sig_container().get_by_sig_id(SignalID.sfx_unique),
		{SFXConstants.unique_key: SFXConstants.Unique.phase_switch},
		false)


func on_exit_state() -> void:
	_pushed_rigid_bodies = false


func update(delta: float):
	e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp))
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)
	
	
	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, 9, 140)
		## todo: switch to SigUtils
		me.SIG_land_wave.emit(me.global_position, AirWave2.AnimID.big_explode)
		_pushed_rigid_bodies = true
	
	_combat_update_is_attacking()
