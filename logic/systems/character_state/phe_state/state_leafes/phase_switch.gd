extends BasePHEAttack


var DECEL_SPEED: float = 11


## attack state as well (used to be neutral)

func initialise_implementation() -> void:
	default_sp.ANGULAR_SPEED = 0.1


func get_active_weapon_names() -> Array[String]:
	return [WeaponNames.bg_aura_weapon]


var _pushed_rigid_bodies: bool = false

func on_exit_state() -> void:
	_pushed_rigid_bodies = false


func update(delta):
	e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp))
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)
	
	
	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, 8, 140)
		_pushed_rigid_bodies = true
	
	_combat_update_is_attacking()
