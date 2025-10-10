extends LegsAction


var fade_interpolator = FloatLinearInterpolator.new()
var fade_time: float = 0.1 # How long to fade extra velocity
var extra_speed: float = 0.0 # Not vector!


func _ready():
	SPEED = 3.0
	ANGULAR_SPEED = 2.0 # Allow slight turning while stopping
	TURN_SPEED = 2.0

	blend_time_by_action = {
		Leg.Act.run: 0.2 + _dev_add_blend
	}

func on_enter_action(input: InputPackage) -> void:
	var prev_speed = legs_sm.get_tranfer_data_by_key("manual_speed")
	if prev_speed and prev_speed is float:
		var rm_start_speed = animator_manager.calculate_animation_start_root_velocity(anim)
		extra_speed = max(0.0, prev_speed - rm_start_speed) # Just the number
		fade_interpolator.initialise(1.0, 0.0, fade_time)
		print_.lsm_action(action_name + pp.on_ent, "prev: %.2f, rm_start: %.2f, extra: %.2f" % [prev_speed, rm_start_speed, extra_speed])
	else:
		extra_speed = 0.0
		fade_interpolator.initialise(0.0, 0.0, 0.0)


func update(input: InputPackage, delta: float):
	rotate_with_input_vector(input, delta)
	_move_with_root(delta)


func _move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	# print_.prefix("~~", "root_vel " + pp.vec3(root_vel))
	var fade_factor = fade_interpolator.update(delta)
	var extra_vel_local = Vector3(0, 0, extra_speed * fade_factor) # Animation +Z
	get_player().velocity = get_player().get_quaternion() * (root_vel + extra_vel_local)

	# print("[RUN_STOP] root_vel: %s (%.2f) | fade: %.2f | extra: %s (%.2f) | final: %s (%.2f)" % [
	# 	pp.vec3(root_vel), root_vel.length(),
	# 	fade_factor,
	# 	pp.vec3(current_extra), current_extra.length(),
	# 	pp.vec3(get_player().velocity), get_player().velocity.length()
	# ])


func animate(): # ▶️
	var start_time_offset := 0.0
	var blend_time: float = blend_time_by_action.get(legs_sm.prev_action.action_name, default_blend_time)
	
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)


var _dev_add_blend = 0
func _input(event):
	_dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	# _next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
