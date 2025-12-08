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

## what weapons should be attacking in this state (depends on animation ofc)
@abstract func get_active_weapon_names() -> Array[String]


## most states can use this in theirs get_active_weapon_names
func default_get_active_weapon_names() -> Array[String]:
	return [WeaponNames.big_pinga_blade]
	

## Combat methods to use in case of overriding on_enter_state/on_exit_state/update
# region

func _combat_set_hit_data_to_all_weapons():
	combat.set_hit_data_to_all_weapons(hit_damage, anim.anim_id)

func _combat_update_is_attacking():
	var _weapon_names = get_active_weapon_names()
	for weapon_name_ in _weapon_names:
		combat.update_weapon_is_attacking(weapon_name_, is_weapon_hurts(weapon_name_, false))

func _combat_reset_all_weapons():
	combat.reset_all_weapons()

# endregion


func on_enter_state() -> void:
	_combat_set_hit_data_to_all_weapons()


func on_exit_state() -> void:
	_combat_reset_all_weapons()


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config, deg_to_rad(angle_adjustment_deg))
	
	e_movement.move_with_root(delta, SCALE_ROOT_FACTOR)
	_combat_update_is_attacking()

var LOG_HURT_B: bool = true


func __log_hurt():
	if LOG_HURT_B:
		print_.prefix(pp.s("// HURT", time_spent(), effective_time_spent(), get_actual_time_spent(), get_real_time_spent()))
