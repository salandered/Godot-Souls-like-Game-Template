extends LegsAction

var SPEED_LERP_TIME: float = 0.5 # Time to interpolate to target speed


func _ready():
	SPEED = 5.0
	TURN_SPEED = 3.2
	ANGULAR_SPEED = 10
	blend_time_by_state = {
		Leg.Act.idle_to_sprint: 0.6,
		Leg.Act.run: 0.3 + _dev_add_blend
	}
	
var speed_interpolator = FloatLinearInterpolator.new()

func on_enter_action(input: InputPackage):
	# means no interpolation. Will be returning constant
	match legs_sm.prev_action.action_name:
		Leg.Act.idle_to_sprint:
			var start_speed = legs_sm.transfer_data.get_by_key_if_action(Leg.Act.idle_to_sprint, "rm_speed")
			if start_speed:
				speed_interpolator.initialise(start_speed, SPEED, SPEED_LERP_TIME)
		# Leg.Act.legs_action_run: # do later

	print_.lsm_action(action_name + pp.on_ent, "")


func on_exit_action():
	animator_manager.reset_global_speed_scale()


func update(input: InputPackage, delta: float):
	var RESULT_SPEED = SPEED
	match legs_sm.prev_action.action_name:
		Leg.Act.idle_to_sprint:
			RESULT_SPEED = speed_interpolator.update(delta)
	
	process_input_vector(input, delta, 1, RESULT_SPEED)
	
	animator_manager.set_global_speed_scale(player.velocity.length() / RESULT_SPEED)


var _dev_add_blend = 0
var _next_anim_correction = 0.12


func animate(): # ▶️
	var start_time_offset := 0.0
	var blend_time: float = blend_time_by_state.get(legs_sm.prev_action.action_name, default_blend_time)
	
	match legs_sm.prev_action.action_name:
		Leg.Act.idle_to_sprint:
			start_time_offset = 0.5
		Leg.Act.run:
			var r = sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				start_time_offset = r
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)


func _input(event):
	SPEED = u._dev_change_param(event, SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)

	# _next_anim_correction = u._dev_change_t67_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
