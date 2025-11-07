extends PlayerAction
class_name BaseAttackAction


## DOCS
## - WARNING: implementation must not use initialise, but initialise_implementation()
## - important to manage weapon via player_sm.combat three times: on_enter, update, on_exit.

## experimental usage with enemy communication
var attack_radius: float = 1.0


var hit_damage: float = 10


var fade_interpolator := FloatLinearInterpolator.new()
var DEFAULT_FADE_TIME: float = 0.4 # how long to fade extra velocity
var DEFAULT_GLOBAL_EXTRA_SPEED_Z := 1.0

var DEFAULT_GLOBAL_EXTRA_SPEED_X := 0.0

var _final_extra_speed_z: float = 0.0
var _final_extra_speed_x: float = 0.0


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

	var _actual_global_speed_extra_z := DEFAULT_GLOBAL_EXTRA_SPEED_Z
	var _actual_global_speed_extra_x := DEFAULT_GLOBAL_EXTRA_SPEED_X
	var _actual_fade_time := DEFAULT_FADE_TIME
	match PREV_ACTION:
		Leg.Act.strafe:
			var result = _adjust_global_extra_speed_to_strafe_direction()
			_actual_global_speed_extra_z = result["Z"]
			_actual_global_speed_extra_x = result["X"]
			_actual_fade_time = result["FADE_TIME"]


	_final_extra_speed_z = _calculate_final_speed_z(_actual_global_speed_extra_z)
	_final_extra_speed_x = _calculate_final_speed_x(_actual_global_speed_extra_x)
	
	fade_interpolator.initialise(1.0, 0.0, _actual_fade_time)
	

func _calculate_final_speed_z(extra_speed_z: float) -> float:
	var _inherited_speed := pm().get_curr_velocity_len()
	var _start_time_offset = start_time_offset.calculate_actual(PREV_ACTION)
	var root_start_speed := get_animator_manager().calculate_animation_start_root_velocity(anim, _start_time_offset, true)
	var _r = max(0.0, _inherited_speed - root_start_speed + extra_speed_z)
	__log_ent("inheritedSp", _inherited_speed, " rootStartSp", root_start_speed, " extraSp Z", _r)

	return _r


func _calculate_final_speed_x(extra_speed_x: float) -> float:
	var _r := extra_speed_x
	__log_ent("extraSp X", _r)
	return _r


func on_exit_action():
	player_sm.combat.reset_active_weapon()


func update(input_: InputPackage, delta):
	if tracks_input_vector() and not player_sm.area_awareness.is_camera_locked():
		pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	
	
	var fade_factor := fade_interpolator.get_current_value()
	var extra_vel_local := Vector3(_final_extra_speed_x * fade_factor, 0, _final_extra_speed_z * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local, true, false)
	
	fade_interpolator.update(delta)

	__log_hurt()

	player_sm.combat.update_active_weapon_is_attacking(weapon_hurts(false))


func _adjust_global_extra_speed_to_strafe_direction() -> Dictionary:
	## animator manager treats prev anim as curr because we are in on_enter_action
	var prev_anim_id = get_animator_manager().get_curr_anim().anim_id
	# todo: should not use animations but strafe dir
	var fade_time: float = DEFAULT_FADE_TIME
	var speed_x: float
	var speed_z: float
	if prev_anim_id == A.strafe.combat_run_f:
		speed_z = 2
		speed_x = 0.0
	elif prev_anim_id == A.strafe.combat_run_b:
		speed_z = -2.0
		speed_x = 0.0
	elif prev_anim_id == A.strafe.strafe_R:
		speed_z = -1.5
		speed_x = -3.0
	elif prev_anim_id == A.strafe.strafe_L:
		speed_z = -1.5
		speed_x = 3.0
	else:
		fade_time = DEFAULT_FADE_TIME
		speed_z = -1.5
		speed_x = 0.0
	return {"X": speed_x, "Z": speed_z, "FADE_TIME": fade_time}
	
## __LOG
var LOG_HURT_B: bool = false


func __log_hurt():
	if LOG_HURT_B:
		print_.prefix(pp.s("// HURT", time_spent(), effective_time_spent(), get_actual_time_spent(), get_real_time_spent()))
