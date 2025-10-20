extends LegsAction


var fade_interpolator = FloatLinearInterpolator.new()
var fade_time: float = 0.3 # how long to fade extra velocity
var extra_speed: float = 0.0

var start_time_offset := 0.0

func _ready():
	default_sp.SPEED = 3.0
	default_sp.ANGULAR_SPEED = 2.0 # allow slight turning while stopping
	default_sp.TURN_SPEED = 2.0

	blend_time_by_action = {
		Leg.Act.run: 0.2 + _dev_add_blend
	}

func on_enter_action(input_: InputPackage) -> void:
	var _inherited_speed = get_player().velocity.length()
	var rm_start_speed = animator_manager.calculate_animation_start_root_velocity(anim)
	extra_speed = max(0.0, _inherited_speed - rm_start_speed)
	fade_interpolator.initialise(1.0, 0.0, fade_time)

	__log_action_ent(
		"inheritedSp: %.2f, startOffset: %.2f, AnimRMStartSp: %.2f, ExtraSp: %.2f" %
		[_inherited_speed, start_time_offset, rm_start_speed, extra_speed])


func update(input_: InputPackage, delta: float):
	pm().rotate_with_input_vector(input_, delta)
	_move_with_root(delta)


func _move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity(true, false)
	var fade_factor = fade_interpolator.update(delta)
	var extra_vel_local = Vector3(0, 0, extra_speed * fade_factor) # Animation +Z
	var final_local_vel = root_vel + extra_vel_local
	get_player().velocity = get_player().get_quaternion() * final_local_vel

	if fade_factor > 0.0:
		__log_action(
			"RootVel.z: %.2f, Fade: %.2f, ExtraVel.z: %.2f, FinLocal.z: %.2f, FinalGlSp: %.2f" %
			[root_vel.z, fade_factor, extra_vel_local.z, final_local_vel.z, get_player().velocity.length()])


func animate(): # ▶️
	var blend_time: float = blend_time_by_action.get(player_sm.get_prev_action().action_name, default_blend_time)
	
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)


var _dev_add_blend = 0
func _input(event):
	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	# _next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
