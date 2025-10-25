extends BasePHEState
class_name BasePHEAttack

var hit_damage: float = 30

var angle_adjustment: float = 0 # radians

var sp_config: SpeedConfig


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)


func on_enter_state():
	combat.set_hit_data_to_active_weapon(hit_damage, anim.anim_id)


func on_exit_state():
	combat.reset_active_weapon()


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config, angle_adjustment)
	
	e_movement.move_with_root(delta)
	manage_weapons()
