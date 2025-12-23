@abstract
class_name BaseAttackAction
extends PlayerAction


## DOCS
## - see BasePHEAttack for reference


## experimental usage with enemy communication
var attack_radius: float = 1.0


var hit_damage: float = 10


var fade_interpolator := FloatLinearInterpolator.new()
var DEFAULT_FADE_TIME: float = 0.4 # how long to fade extra velocity
var DEFAULT_GLOBAL_EXTRA_SPEED_Z := 1.0

var DEFAULT_GLOBAL_EXTRA_SPEED_X := 0.0

var _final_extra_speed_Z: float = 0.0
var _final_extra_speed_X: float = 0.0


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 2
	extra_root_speed_Z.set_specific(DEFAULT_GLOBAL_EXTRA_SPEED_Z)
	initialise_implementation()


# to override instead of initialise
@abstract func initialise_implementation() -> void


## what weapon could be attacking in this action.
## 	- currently player may have only one weapon
## 	- switch of weapons is perfomed on the combat level
## => we rely on combat and return only one id. 
func get_active_weapon_id() -> String:
	var _ids := combat.get_active_weapon_ids()
	if len(_ids) != 1:
		__log_warn(pp.s("currently 1 active weapon is expected for player, got", len(_ids)))
		return ""
	return _ids[0]

	
## Combat methods to use in case of overriding on_enter_state/on_exit_state/update
# region

func _combat_set_hit_data():
	player_sm.combat.set_hit_data(get_active_weapon_id(), hit_damage, anim.anim_id)

func _combat_update_is_attacking(__log: bool = false):
	var _weapon_id := get_active_weapon_id()
	if _weapon_id != "":
		player_sm.combat.update_weapon_is_attacking(_weapon_id, is_weapon_hurts(_weapon_id, __log))

func _combat_reset():
	player_sm.combat.reset_weapon_by_id(get_active_weapon_id())

# endregion


func on_enter_action(input_: InputPackage):
	get_animator_manager().force_stop_overlay()
	_combat_set_hit_data()

	if player_sm.area_awareness.is_camera_locked():
		default_sp.ANGULAR_SPEED = 2
	else:
		default_sp.ANGULAR_SPEED = 4

	var _speed_extra_Z := extra_root_speed_Z.calculate_actual(PREV_ACTION)
	var _speed_extra_X := DEFAULT_GLOBAL_EXTRA_SPEED_X
	match PREV_ACTION:
		Leg.Act.strafe:
			var result := _adjust_extra_speed_to_strafe_direction()
			_speed_extra_Z = result["Z"]
			_speed_extra_X = result["X"]

	var r := calculate_extra_root_speed(_speed_extra_Z, _speed_extra_X)
	_final_extra_speed_Z = r.z
	_final_extra_speed_X = r.x
	fade_interpolator.initialise(1.0, 0.0, DEFAULT_FADE_TIME)
	

func on_exit_action():
	_combat_reset()


func update(input_: InputPackage, delta: float):
	if tracks_input_vector() and not player_sm.area_awareness.is_camera_locked():
		pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	if player_sm.area_awareness.is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		pm().look_at_target(delta)
	
	var fade_factor := fade_interpolator.update(delta)
	var extra_vel_local := Vector3(_final_extra_speed_X * fade_factor, 0, _final_extra_speed_Z * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local)
	
	__log_hurt()

	_combat_update_is_attacking()


func _adjust_extra_speed_to_strafe_direction() -> Dictionary[String, float]:
	## animator manager treats prev anim as curr because we are in on_enter_action
	var prev_anim_id := get_animator_manager().get_curr_anim().anim_id
	# todo: should not use animations but strafe dir
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
		speed_z = -1.5
		speed_x = 0.0
	return {"X": speed_x, "Z": speed_z}
	
## __LOG
var LOG_HURT_B: bool = false


func __log_hurt():
	if LOG_HURT_B:
		print_.prefix(pp.s("// HURT", time_spent(), effective_time_spent(), get_actual_time_spent(), get_real_time_spent()))
