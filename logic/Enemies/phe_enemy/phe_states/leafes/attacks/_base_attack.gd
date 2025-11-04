extends BasePHELeaf
class_name BasePHEAttack

var hit_damage: float = 30

var angle_adjustment: float = 0 # radians

var sp_config: SpeedConfig

var SCALE_ROOT_FACTOR := 1.0

## DOCS:
##   DANGER: implementation must not use initialise, but initialise_implementation()


func initialise() -> void:
	TIME_REMAINING_TO_END = 0.2
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)
	initialise_implementation()


# to override instead of initialise
func initialise_implementation():
	pass


func on_enter_state() -> void:
	combat.set_hit_data_to_weapon(hit_damage, anim.anim_id)


func on_exit_state() -> void:
	combat.reset_active_weapon()


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config, angle_adjustment)
	
	e_movement.move_with_root(delta, SCALE_ROOT_FACTOR)
	manage_weapons()
