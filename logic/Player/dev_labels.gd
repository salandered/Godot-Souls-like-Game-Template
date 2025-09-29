extends Node


@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_state_info: Label = $LabelStateInfo
@onready var label_subs_psm: Label = $LabelSubsPSM
@onready var label_4: Label = $Label4
@onready var modifier_ar: Label = %modifier_ar
@onready var modifier_ar_2: Label = %modifier_ar_2

@onready var player: Princess = $".."

var _visible: bool = true

var frequency := 2

var all_labels = []

func _ready() -> void:
	all_labels = [
		label,
		label_2,
		label_state_info,
		label_subs_psm,
		label_4,
		modifier_ar,
		modifier_ar_2
	]

func _process(delta: float) -> void:
	if u.fr(false) % frequency == 0:
		_label_player_info()
		_label_modifer_animator_info()
		_label_state_info()

func _input(event):
	if event.is_action_released("kp_7"):
		_visible = not _visible
		for l: Label in all_labels:
			l.visible = _visible


func _label_player_info():
	var p_pos = player.model.global_position
	var nest_pos := player.fancy_camera.nest.global_position
	var camera_pos := player.fancy_camera.camera.global_position
	
	label.text = ""
	label.text = "player to nest " + "%10.3f" % p_pos.distance_to(nest_pos)
	label.text += "\n player to cam " + "%10.3f" % p_pos.distance_to(camera_pos)

	var free_offset = player.fancy_camera.free_state.free_offset.length() if player.fancy_camera.free_state.free_offset else 0.0
	var lock_offset := player.fancy_camera.locked_state.lock_offset.length() if player.fancy_camera.locked_state.lock_offset else 0.0
	label_2.text = "free off " + "%10.3f" % free_offset
	label_2.text += "\n lock off " + "%10.3f" % lock_offset
	label_2.text += "\n FRAME " + u.fr()


func _label_state_info():
	var c_s := player.model.player_sm.current_state
	#var limp_anim := player.model.limp
	if not c_s:
		label_state_info.text = "NO current state"
		return
	if not c_s.current_action:
		label_state_info.text += "\nNO current action"
		return
	if not c_s.legs_sm.current_behavior:
		label_state_info.text += "\nNO legs behavior"
		return
	if not c_s.legs_sm.current_action:
		label_state_info.text += "\nNO legs behavior action"
		return
	label_state_info.text = "state  %20s   act  %20s " % [str(c_s.state_name), str(c_s.current_action.action_name)]
	label_state_info.text += "\nlegs  %20s   act  %20s " % [str(c_s.legs_sm.current_behavior.behavior_name), str(c_s.legs_sm.current_action.action_name)]
	label_state_info.text += "\nprogress pl action %6.2f  l action  %6.2f " % [c_s.current_action.get_progress(), c_s.legs_sm.current_action.get_progress()]


func _label_modifer_animator_info():
	var t_ar := player.model.animator_manager.full_body
	var l_ar := player.model.animator_manager.legs

	modifier_ar.text = __one_animator_data(t_ar)
	modifier_ar_2.text = __one_animator_data(l_ar)

var _prev_blend_text = ""

func __one_animator_data(ar: ModifierAnimator) -> String:
	var c_an = ar.curr_anim
	var text := ""
	text += "  infl " + str(ar.influence)
	text += "\n %25s" % [c_an.anim_name if c_an else "-None-"]
	text += "  loop:" + str(ar.curr_anim_looping)
	text += "\n %5.2f" % [ar.curr_anim_progress]
	

	text += "\nAnim:  Start %5.2f | End %5.2f | Duration %5.2f | Native len %5.2f\n" % [
		c_an.start_time,
		c_an.end_time,
		c_an.duration,
		c_an.native_anim.length
	]

	if ar.is_blending:
		var blend_text = ""
		blend_text += "\n blend " + "%6.1f" % (ar.blending_percentage * 100) + "%"
		blend_text += " " + "%8.2f" % ar.blend_time_spent + "/" + "%8.2f" % ar.blend_duration
		blend_text += "\n from: " + (ar.prev_anim.anim_name if ar.prev_anim else "-None-")
		blend_text += "\n speed scale: %4.2f" % [ar.global_speed_scale]
		text += blend_text
		_prev_blend_text = blend_text
	else:
		text += _prev_blend_text

	return text

# FROM OUTSIDE THE PLAYER

func _label_enemy_info(enemy: SECharacter):
	pass
	# var e_pos = enemy.global_position
	# var p_pos = player.model.global_position
	# label_state_info.text = "enemy to pl " + "%5.1f" % e_pos.distance_to(p_pos)
	# label_state_info.text += "\n st-time %7.3f %7.3f" % [enemy.current_state.get_progress(), enemy.current_state.get_iteration_progress()]
