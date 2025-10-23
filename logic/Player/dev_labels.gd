extends Node


@onready var label_inputs: Label = %label_inputs
@onready var label_cam: Label = %label_cam
@onready var label_state_info: Label = %LabelStateInfo
@onready var modifier_ar: Label = %modifier_ar

@onready var player: Princess = $".."

var _visible: bool = true

var all_labels = []


func _ready() -> void:
	all_labels = [
		label_inputs,
		# label_cam,
		label_state_info,
		modifier_ar,
	]


func _process(delta: float) -> void:
	if u.fr(false) % 2 == 0:
		# _label_camera_info()
		_label_modifier_animator_info()
		_label_state_info()

	if u.fr(false) % 1 == 0:
		_label_inputs()


func _input(event):
	if event.is_action_released("kp_7"):
		_visible = not _visible
		for l: Label in all_labels:
			l.visible = _visible


func _label_inputs():
	var input_: InputPackage = __pl().model.area_awareness.last_input_package
	var vel_by_input_ = __pl().player_movement.__velocity_by_input(input_, Constants.ONE_FRAME)
	var t := ""
	t += "input_dir " + pp.vec2(input_.input_direction)
	t += "  len %5.2f" % [input_.input_direction.length()]
	t += "  forward strength %5.2f" % [input_.forward_input]
	t += "  orbit (hor) strength %5.2f" % [input_.orbit_input]
	t += "\nactions: " + pp._array(input_.actions)
	t += "\ncombat: " + pp._array(input_.combat_actions)
	t += "\ntarget lock " + str(input_.target_lock)
	t += "\ncam forward %5.2f  orbit %5.2f" % [input_.forward_input, input_.orbit_input]
	t += "\n vel_by_input_" + pp.s(pp.vec3(vel_by_input_), vel_by_input_.length())
	t += "\n vel_by_input_ norm" + pp.s(pp.vec3(vel_by_input_.normalized()), vel_by_input_.normalized().length())
	
	var curr_dir = "-none-"
	t += "\n 8-dir-strafe   " + Direction.name_(input_.detect_strafe_dir())
	var relative_dir = __pl().player_movement.detect_dir_relative_to_facing(input_, Constants.ONE_FRAME)
	t += "\n 8-dir-new   " + Direction.name_(relative_dir)
		
	t += "\nhealth/stamina %5.2f/%5.2f" % [
		 __pl().model.feelings._current_health,
		 __pl().model.feelings._current_stamina
		]
	label_inputs.text = t


func _label_camera_info():
	var p_pos = player.model.global_position
	var nest_pos := __cam().nest.global_position
	var camera_pos := __cam().camera.global_position
	
	label_cam.text = "player to nest " + "%8.2f" % p_pos.distance_to(nest_pos)
	label_cam.text += "\n player to cam " + "%8.2f" % p_pos.distance_to(camera_pos)

	var free_off = __cam().free_state.free_offset.length() if __cam().free_state.free_offset else 0.0
	var lock_off := __cam().locked_state.lock_offset.length() if __cam().locked_state.lock_offset else 0.0
	label_cam.text += "\nfree off " + "%8.2f" % free_off
	label_cam.text += "\n lock off " + "%8.2f" % lock_off
	

func _label_state_info():
	var c_s := __c_s()

	var t := ""
	var error: bool = false
	if not c_s:
		t += em.warn + "NO current state"
		error = true
	if not c_s.legs_sm.current_behavior:
		t += em.warn + "\nNO legs behavior"
		error = true
	if not c_s.legs_sm.get_curr_action():
		t += em.warn + "\nNO legs behavior action"
		error = true
	if not __pl_sm().get_curr_action():
		t += em.warn + "\n"
		error = true
	if not __pl_sm().get_prev_action():
		t += em.warn + "\n"
		error = true
	if error:
		label_state_info.text = t
		return


	var curr_st = c_s.state_name
	var curr_st_act = "NONE"
	var curr_st_act_time_spent = 0.0
	if c_s.curr_state_action:
		curr_st_act = c_s.curr_state_action.action_name
		curr_st_act_time_spent = c_s.curr_state_action.time_spent()
	
	var curr_l_b = c_s.legs_sm.current_behavior.behavior_name
	var curr_l_act = c_s.legs_sm.get_curr_action().action_name
	var curr_l_act_time_spent = c_s.legs_sm.get_curr_action().time_spent()
	var curr_gl_act = __pl_sm().get_curr_action().action_name
	var prev_gl_act = __pl_sm().get_prev_action().action_name
	
	t += "state/st act  %20s %20s " % [curr_st, curr_st_act]
	t += "\nl_beh / l_act  %20s %20s " % [curr_l_b, curr_l_act]
	t += "\nAct: gl/st/legs   %20s %20s %20s " % [curr_gl_act, curr_st_act, curr_l_act]
	t += "\nAct: gl from prev  %20s (%16s)" % [curr_gl_act, prev_gl_act]
	t += "\nprogress pl action %6.2f  l action  %6.2f " % [curr_st_act_time_spent, curr_l_act_time_spent]

	label_state_info.text = t


func _label_modifier_animator_info():
	var animator := player.model.animator_manager.full_body

	modifier_ar.text = animator.__log_state()
	# modifier_ar_2.text = __one_animator_data(l_ar)


func __l_action(act_name) -> LegsAction:
	if __pl().model.legs_sm:
		if __pl().model.legs_sm._current_action:
			if __pl().model.legs_sm._current_action.action_name == act_name:
				return __pl().model.legs_sm._current_action
	return null


func __pl():
	return player

func __c_s() -> PlayerState:
	return __pl().model.player_sm.current_state

func __pl_sm() -> PlayerSM:
	return __pl().model.player_sm

func __cam() -> FancyCamera:
	return __pl().fancy_camera

# FROM OUTSIDE THE PLAYER

func _label_enemy_info(enemy: SECharacter):
	pass
	# var e_pos = enemy.global_position
	# var p_pos = player.model.global_position
	# label_state_info.text = "enemy to pl " + "%5.1f" % e_pos.distance_to(p_pos)
	# label_state_info.text += "\n st-time %7.3f %7.3f" % [enemy.current_state.get_progress(), enemy.current_state.get_iteration_progress()]
