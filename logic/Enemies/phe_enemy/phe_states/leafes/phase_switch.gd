extends BasePHEAttack


var DECEL_SPEED: float = 11


## attack state as well (used to be neutral)

func initialise_implementation() -> void:
	default_sp.ANGULAR_SPEED = 0.1


func get_active_weapon_names() -> Array[String]:
	return [WeaponNames.bg_aura_weapon]

func update(delta):
	e_movement.rotate_towards_player(delta, SpeedConfig.new(default_sp))
	e_movement.smooth_xz_stop(delta, DECEL_SPEED)
	_combat_update_is_attacking()
