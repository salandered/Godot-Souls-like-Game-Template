@abstract
class_name BasePHEAttack
extends BasePHELeaf

var hit_damage: float = 20

var angle_adjustment_deg: float = 0

var sp_config: SpeedConfig

var SCALE_ROOT_FACTOR := 1.0


## DOCS:
##   WARNING: implementation must not use initialise, but initialise_implementation()
##            i made it @abstract so it's easier to follow this pattern.
##            All weapons must set at least their hit_damage, anyway
##  Implementations must use combat methods in case of overrding base state methods       


func initialise() -> void:
	TIME_REMAINING_TO_END = 0.2
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)
	initialise_implementation()


@abstract func initialise_implementation() -> void


var default_attack_weapons: Array[String] = [WeaponID.big_pinga_blade]

## what weapons should be attacking in this state (depends on animation)
## to override
func get_anim_active_weapon_ids() -> Array[String]:
	return default_attack_weapons


## Combat methods to use in case of overriding on_enter_state/on_exit_state/update
# region

func _combat_set_hit_data():
	for weapon_id in get_anim_active_weapon_ids():
		combat.set_hit_data(
			weapon_id,
			hit_damage,
			anim.anim_id,
			animator_manager.get_global_speed_scale(),
			state_name,
			)

func _combat_update_is_attacking():
	var _weapon_ids := get_anim_active_weapon_ids()
	for _id in _weapon_ids:
		combat.update_weapon_is_attacking(_id, is_weapon_hurts(_id, false))

func _combat_reset():
	for weapon_id in get_anim_active_weapon_ids():
		combat.reset_weapon_by_id(weapon_id)

# endregion


func on_enter_state() -> void:
	_combat_set_hit_data()


func on_exit_state() -> void:
	_combat_reset()


func update(delta: float):
	e_movement.rotate_towards_player(delta, sp_config, deg_to_rad(angle_adjustment_deg))
	
	e_movement.move_with_root(delta, SCALE_ROOT_FACTOR)
	_combat_update_is_attacking()


var LOG_HURT_B: bool = false


func __log_hurt():
	if LOG_HURT_B:
		print_.prefix(pp.s("// HURT", time_spent(), effective_time_spent(), get_actual_time_spent(), get_real_time_spent()))
