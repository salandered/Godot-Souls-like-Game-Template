extends Node


@onready var label_inputs: Label = %label_inputs
@onready var label_cam: Label = %label_cam
@onready var label_state_info: Label = %LabelStateInfo
@onready var modifier_ar: Label = %modifier_ar
@onready var modifier_ar_2: Label = %modifier_ar_2

@onready var player: Princess = $".."

var _visible: bool = true

var all_labels = []

func _ready() -> void:
	all_labels = [
		label_inputs,
		label_cam,
		label_state_info,
		modifier_ar,
		# modifier_ar_2
	]
	modifier_ar_2.visible = false

func _process(delta: float) -> void:
	if u.fr(false) % 2 == 0:
		_label_player_info()
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
	var last_input: InputPackage = player.model.area_awareness.last_input_package
	var vel_by_input_ = player.model.__velocity_by_input(last_input, 0.016)
	var t := ""
	t += "input_dir " + pp.vec2(last_input.input_direction)
	t += "  len %5.2f" % [last_input.input_direction.length()]
	t += "  forward strength %5.2f" % [last_input.forward_input]
	t += "  orbit (hor) strength %5.2f" % [last_input.orbit_input]
	t += "\nactions: " + pp._array(last_input.actions)
	t += "\ncombat: " + pp._array(last_input.combat_actions)
	t += "\ntarget lock " + str(last_input.target_lock)
	t += "\ncam forward %5.2f  orbit %5.2f" % [last_input.forward_input, last_input.orbit_input]
	t += "\n vel_by_input_" + pp.s(pp.vec3(vel_by_input_), vel_by_input_.length())
	t += "\n vel_by_input_ norm" + pp.s(pp.vec3(vel_by_input_.normalized()), vel_by_input_.normalized().length())
	label_inputs.text = t


func _label_player_info():
	var p_pos = player.model.global_position
	var nest_pos := player.fancy_camera.nest.global_position
	var camera_pos := player.fancy_camera.camera.global_position
	
	label_cam.text = "player to nest " + "%8.2f" % p_pos.distance_to(nest_pos)
	label_cam.text += "\n player to cam " + "%8.2f" % p_pos.distance_to(camera_pos)

	var free_offset = player.fancy_camera.free_state.free_offset.length() if player.fancy_camera.free_state.free_offset else 0.0
	var lock_offset := player.fancy_camera.locked_state.lock_offset.length() if player.fancy_camera.locked_state.lock_offset else 0.0
	label_cam.text += "\nfree off " + "%8.2f" % free_offset
	label_cam.text += "\n lock off " + "%8.2f" % lock_offset
	

func _label_state_info():
	var c_s := player.model.player_sm.current_state
	if not c_s:
		label_state_info.text = "NO current state"
		return
	if not c_s.current_action:
		label_state_info.text += "\nNO current action"
		return # WARNING: not best idea to return. other data will be skipped
	if not c_s.legs_sm.current_behavior:
		label_state_info.text += "\nNO legs behavior"
		return
	if not c_s.legs_sm.current_action:
		label_state_info.text += "\nNO legs behavior action"
		return
	label_state_info.text = "state %20s   act %20s " % [str(c_s.state_name), str(c_s.current_action.action_name)]
	label_state_info.text += "\nlegs %20s   act %20s " % [str(c_s.legs_sm.current_behavior.behavior_name), str(c_s.legs_sm.current_action.action_name)]
	label_state_info.text += "\nprogress pl action %6.2f  l action  %6.2f " % [c_s.current_action.time_spent(), c_s.legs_sm.current_action.time_spent()]


func _label_modifier_animator_info():
	var animator := player.model.animator_manager.full_body

	modifier_ar.text = animator.__log_state()
	# modifier_ar_2.text = __one_animator_data(l_ar)


# FROM OUTSIDE THE PLAYER

func _label_enemy_info(enemy: SECharacter):
	pass
	# var e_pos = enemy.global_position
	# var p_pos = player.model.global_position
	# label_state_info.text = "enemy to pl " + "%5.1f" % e_pos.distance_to(p_pos)
	# label_state_info.text += "\n st-time %7.3f %7.3f" % [enemy.current_state.get_progress(), enemy.current_state.get_iteration_progress()]
