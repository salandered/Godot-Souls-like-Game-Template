extends PlayerAction
class_name BaseAttackAction


## DOCS
## - WARNING: implementation must not use initialise, but initialise_implementation()
## - important to manage weapon via player_sm.combat three times: on_enter, update, on_exit.

## experimental usage with enemy communication
var attack_radius: float = 1.0


var hit_damage: float = 10


var fade_interpolator := FloatLinearInterpolator.new()
var FADE_TIME: float = 0.4 # how long to fade extra velocity
var extra_speed: float = 0.0

var GLOBAL_EXTRA_SPEED := 1.0


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 2
	initialise_implementation()


# to override instead of initialise
func initialise_implementation():
	pass


func on_enter_action(input_: InputPackage):
	player_sm.combat.set_hit_data_to_active_weapon(hit_damage, anim.anim_id)
	if player_sm.area_awareness.is_camera_locked():
		default_sp.ANGULAR_SPEED = 2
	else:
		default_sp.ANGULAR_SPEED = 4

	var _inherited_speed := pm().get_curr_velocity_len()
	var _start_time_offset = start_time_offset.calculate_actual(PREV_ACTION)
	var root_start_speed := get_animator_manager().calculate_animation_start_root_velocity(anim, _start_time_offset, true)
	extra_speed = max(0.0, _inherited_speed - root_start_speed + GLOBAL_EXTRA_SPEED)
	fade_interpolator.initialise(1.0, 0.0, FADE_TIME)
	
	__log_action_ent("inheritedSp", _inherited_speed, " rootStartSp", root_start_speed, " extraSp", extra_speed)


func on_exit_action():
	player_sm.combat.reset_active_weapon()


func update(input_: InputPackage, delta):
	if tracks_input_vector():
		pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	
	
	var fade_factor := fade_interpolator.get_current_value()
	var extra_vel_local := Vector3(0, 0, extra_speed * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local, true, false)
	
	fade_interpolator.update(delta)

	__log_hurt()

	player_sm.combat.update_is_attacking(weapon_hurts())


var LOG_HURT_B: bool = false


func __log_hurt():
	if LOG_HURT_B:
		print_.prefix(pp.s("// HURT", time_spent(), effective_time_spent(), get_actual_time_spent(), get_real_time_spent()))
