extends PlayerAction
class_name DodgeAction

@export var dodge_x_curve: Curve # bell-curve


var SECOND_DODGE_FEATURE: bool = false


var PEAK_SPEED_BOOST: float = 0.0
var END_SPEED_BOOST: float = 0.0


var PEAK_SPEED: float = 6.0
var END_SPEED: float = 2.5
var dodge_x_dur_correction: float = 0.0

var speed_x_interpolator := HillInterpolator.new()


const ANIM_F := A.dodge.dodge_F
const ANIM_B := A.dodge.dodge_B
const ANIM_R := A.dodge.dodge_R
const ANIM_L := A.dodge.dodge_L

const SPEED_R: float = 1.0
const SPEED_L: float = 1.0

var curr_dodge_dir: DodgeDirection

# todo: trace several dodges in a row
var second_dodge: bool = false


var upper_body_mask: Array[int]

func initialise() -> void:
	curr_dodge_dir = DodgeDirection.new(SPEED_R, ANIM_R, SPEED_L, ANIM_L, SPEED_R, ANIM_F, SPEED_L, ANIM_B)
	blend_time.set_by_prev_action({
		Leg.Act.run: 0.1, # or 0.1?
	})

	default_sp.ANGULAR_SPEED = 1
	upper_body_mask = BoneMask.get_upper_body(true)

	GlobalSignal.player_dodge_increase.connect_(_on_dodge_increase)


func _calculate_anim_effective_duration(actual_anim: AnimationData) -> float:
	var _anim_start := actual_anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0)
	var _anim_end := actual_anim.get_marker_time_by_name(MarkerName.TO_RUN, 1.0)
	start_time_offset.set_specific(_anim_start) # WARNING: important side effect
	return _anim_end - _anim_start


func on_enter_action(input_: InputPackage) -> void:
	get_animator_manager().reset_global_speed_scale()
	var _original_dir: Direction.Dir
	# TODO: while sprinting or not is_camera_locked it almost like another dodge state/action 
	if pm().get_area_awareness().is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		_original_dir = input_.detect_strafe_dir()
	else:
		_original_dir = pm().detect_dir_relative_to_facing(input_, Const.ONE_FRAME)
	curr_dodge_dir.set_direction_simplified(_original_dir)

	# INTERPOLATOR
	var _inherited_speed := pm().get_curr_velocity_len()
	var _actual_anim := anim_container.get_by_anim_id(curr_dodge_dir.get_curr_anim_id())
	var _anim_effective_dur := _calculate_anim_effective_duration(_actual_anim)

	# important to reset here
	PEAK_SPEED = 6.0
	END_SPEED = 2.5
	match curr_dodge_dir.get_curr_dir():
		curr_dodge_dir.Dir.FORWARD, curr_dodge_dir.Dir.NEUTRAL:
			PEAK_SPEED = 6.0
		curr_dodge_dir.Dir.BACKWARD:
			PEAK_SPEED += 2.0
		curr_dodge_dir.Dir.RIGHT, curr_dodge_dir.Dir.LEFT:
			PEAK_SPEED += 2.0
			END_SPEED = 2.8
	
	match PREV_ACTION:
		Leg.Act.sprint:
			PEAK_SPEED += 1.0
			END_SPEED = 3.5
		PS.Act.dodge:
			PlayerStats.increase_count_dodge()
			second_dodge = true
			__log_ent(em.pin, "second_dodge raised!")
		_:
			PlayerStats.reset_count_dodge()


	if second_dodge:
		PEAK_SPEED -= 2.0
		END_SPEED -= 0.3

	speed_x_interpolator.initialise(
		_inherited_speed + END_SPEED_BOOST,
		END_SPEED + END_SPEED_BOOST,
		PEAK_SPEED + PEAK_SPEED_BOOST,
		dodge_x_curve,
		_anim_effective_dur + dodge_x_dur_correction)
	
	__log_ent("curr_dodge_dir", curr_dodge_dir.pp_curr_dir(),
		"from strafe", Direction.name_(_original_dir),
		"calc_anim_dur", _anim_effective_dur,
		"PEAK_SPEED", PEAK_SPEED,
		"_inherited_speed", _inherited_speed,
		"END_SPEED", END_SPEED)


func on_exit_action() -> void:
	second_dodge = false
	speed_x_interpolator.reset()


func update(input_: InputPackage, delta: float) -> void:
	if pm().get_area_awareness().is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		pm().look_at_target(delta)

	var current_speed := speed_x_interpolator.update(delta)
	
	var _curr_world_vector := curr_dodge_dir.current_world_vector(get_player().basis)
	get_player().velocity = _curr_world_vector * current_speed

	# not in this version
	# if tracks_input_vector():
		# pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))


func animate(): # ▶️
	blend_time.set_specific(0.1)
	
	anim = anim_container.get_by_anim_id(curr_dodge_dir.get_curr_anim_id())
	
	set_anim_to_play()

	# if SECOND_DODGE_FEATURE:
	# 	if second_dodge and curr_dodge_dir.is_horizontal():
	# 		var anim_id_to_overlay: StringName
	# 		if curr_dodge_dir.get_curr_dir() == DodgeDirection.Dir.RIGHT:
	# 			anim_id_to_overlay = A.dodge.dodge_R_head
	# 		elif curr_dodge_dir.get_curr_dir() == DodgeDirection.Dir.LEFT:
	# 			anim_id_to_overlay = A.dodge.dodge_L_head
	# 		else:
	# 			__log_upd("Unexpected direction:", curr_dodge_dir.pp_curr_dir())
	# 			anim_id_to_overlay = A.dodge.dodge_R_head # fallback
	# 		# experimental but cool
	# 		var _overlay_config := OverlayConfig.new(
	# 			OverlayConfig.Weight.new(__weight),
	# 			BlendConfig.new(0.1, 0.15, 0.2),
	# 			__sp_scale,
	# 			upper_body_mask)
	# 		get_animator_manager().set_overlay_anim(anim_id_to_overlay, _overlay_config)


var __weight := 0.8
var __sp_scale := 1.2

# func _unhandled_input(event):
# 	# END_SPEED = InputUtils._dev_change_param(event, END_SPEED, "END_SPEED", 0.5)
# # 	# 	0.5, "dev_speed_down", RawAction.DEV_speed_up)
# 	# __weight = InputUtils._dev_change_t12_param(event, __weight, "__weight", 0.1)
# 	__sp_scale = InputUtils._dev_change_t34_param(event, __sp_scale, "__sp_scale", 0.1)
# # 	GRAVITY_DURING_JUMP = InputUtils._dev_change_t58_param(event, GRAVITY_DURING_JUMP, "GRAVITY_DURING_JUMP", 0.5)


func _on_dodge_increase(payload: Dictionary[StringName, Variant]) -> void:
	# prints("_on_speed_increase", "triggered")
	var value = payload.get(SPS.amount_field)
	if value and (value is float or value is int):
		PEAK_SPEED_BOOST += value
		END_SPEED_BOOST += float(value) / 2.0