extends LegsAction

var SPEED_LERP_TIME: float = 0.5 # Time to interpolate to target speed

var accel_time_from_turn: float = 0.3 # How long to reach full speed

var speed_from_idle = FloatLinearInterpolator.new()
var speed_from_turn = FloatLinearInterpolator.new()
var angular_from_turn = FloatLinearInterpolator.new()

func _ready():
	default_sp.SPEED = 5.0
	default_sp.TURN_SPEED = 3.2
	default_sp.ANGULAR_SPEED = 10

	
	blend_time_by_action = {
		Leg.Act.idle_to_sprint: 0.6,
		Leg.Act.run: 0.3,
		Leg.Act.fast_turn_180: 0.2
	}
	

func on_enter_action(input_: InputPackage):
	# means no interpolation. Will be returning constant
	match player_sm.get_prev_action().action_name:
		Leg.Act.idle_to_sprint:
			var _start_speed = player_sm.get_tranfer_data_by_key("rm_speed")
			if _start_speed:
				speed_from_idle.initialise(_start_speed, default_sp.SPEED, SPEED_LERP_TIME)
		# Leg.Act.legs_action_run: # do later
		Leg.Act.fast_turn_180:
			var _start_speed = player_sm.get_tranfer_data_by_key("rm_speed")
			if _start_speed:
				speed_from_turn.initialise(_start_speed, default_sp.SPEED, accel_time_from_turn)
			else:
				speed_from_turn.initialise(default_sp.SPEED, default_sp.SPEED, 0)
			angular_from_turn.initialise(default_sp.ANGULAR_SPEED / 10, default_sp.ANGULAR_SPEED, 1.0)

	print_.lsm_action(action_name + pp.on_ent, "")


func on_exit_action():
	animator_manager.reset_global_speed_scale()


func update(input_: InputPackage, delta: float):
	var CURR_SPEED = default_sp.SPEED # default actual speed
	var CURR_ANGULAR_SPEED = default_sp.ANGULAR_SPEED

	match player_sm.get_prev_action().action_name:
		Leg.Act.idle_to_sprint:
			CURR_SPEED = speed_from_idle.update(delta)
		Leg.Act.fast_turn_180:
			CURR_SPEED = speed_from_turn.update(delta)
			# CURR_ANGULAR_SPEED = angular_from_turn.update(delta)
	
	# prints("~~~~~~~~~~~~~~", CURR_SPEED, CURR_ANGULAR_SPEED)
	var speed_config = SpeedConfig.new(default_sp, 1.0, CURR_SPEED, CURR_ANGULAR_SPEED)
	pm().process_input_vector(input_, delta, speed_config)

	animator_manager.set_global_speed_scale(get_player().velocity.length() / CURR_SPEED)


func animate(): # ▶️
	var start_time_offset := 0.0
	var blend_time: float = blend_time_by_action.get(player_sm.get_prev_action().action_name, default_blend_time)
	
	match player_sm.get_prev_action().action_name:
		Leg.Act.idle_to_sprint:
			start_time_offset = 0.5
		Leg.Act.run:
			var r = sync_with_prev_loco_anim(_next_anim_correction)
			if r != -1:
				start_time_offset = r
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)


var _dev_add_blend = 0
var _next_anim_correction = 0.12


func _input(event):
	default_sp.SPEED = u._dev_change_param(event, default_sp.SPEED, "SPEED", 6, "dev_speed_down", "dev_speed_up")
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)

	# _next_anim_correction = u._dev_change_t67_param(event, _next_anim_correction, "_next_anim_correction", 0.02)
