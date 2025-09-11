extends Node


@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var label_4: Label = $Label4
@onready var label_5: Label = $Label5
@onready var label_6: Label = $Label6

@onready var player: Princess = $".."


var frequency := 4

func _process(delta: float) -> void:
	if Engine.get_process_frames() % frequency == 0:
		_label_player_info()
		_label_sk_m_info()
		_label_state_info()

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
	var t_anim := c_s.player_sm.torso_animator
	var l_anim := c_s.legs_sm.legs_animator
	#var limp_anim := player.model.limp
	if not c_s:
		label_3.text = "NO current state"
		return
	if not c_s.current_action:
		label_3.text += "\nNO current action"
		return
	if not c_s.legs_sm.current_behavior:
		label_3.text += "\nNO legs behavior"
		return
	if not c_s.legs_sm.current_action:
		label_3.text += "\nNO legs behavior action"
		return
	label_3.text = "state  %7s     act  %7s " % [str(c_s.state_name), str(c_s.current_action.action_name)]
	label_3.text += "\nlegs  %7s   act  %7s " % [str(c_s.legs_sm.current_behavior.behavior_name), str(c_s.legs_sm.current_action.action_name)]
	label_3.text += "\n speed scale: %4.2f  %4.2f" % [t_anim.speed_scale, l_anim.speed_scale]
	label_3.text += "\n followers: %15s  %15s" % [str(t_anim.follower), str(l_anim.follower)]
	# label_3.text += "\n influences: %4.2f %4.2f %4.2f | active: %4s %4s %4s" % \
	# 	[t_anim.influence, l_anim.influence, limp_anim.influence, \
	# 	str(t_anim.active), str(l_anim.active), str(limp_anim.active)]
	label_3.text += "\n influences: %4.2f %4.2f | active: %4s %4s" % \
		[t_anim.influence, l_anim.influence, \
		str(t_anim.active), str(l_anim.active), ]

func _label_sk_m_info():
	var full_body_a := player.model.full_body
	var torso_a := player.model.torso
	var legs_a := player.model.legs_animator

	label_4.text = __sk_m_label(full_body_a)
	label_5.text = __sk_m_label(torso_a)
	label_6.text = __sk_m_label(legs_a)


func __sk_m_label(animator: ModifierAnimator) -> String:
	var text := ""
	text += (animator.current_anim.resource_name if animator.current_anim else "-None-")
	text += "\n %5.2f" % [animator.current_anim_progress]
	text += "  l:" + str(animator.current_anim_cycling)

	if animator.is_blending:
		text += "\nb" + "%5.1f" % (animator.blending_percentage * 100) + "%"
		text += " " + "%7.2f" % animator.blend_time_spent + "/" + "%7.2f" % animator.blend_duration
		text += "\n from: " + (animator.previous_anim.resource_name if animator.previous_anim else "-None-")

	return text

# FROM OUTSIDE THE PLAYER

func _label_enemy_info(enemy: SECharacter):
	var e_pos = enemy.global_position
	var p_pos = player.model.global_position
	label_3.text = "enemy to pl " + "%5.1f" % e_pos.distance_to(p_pos)
	label_3.text += "\n st-time %7.3f %7.3f" % [enemy.current_state.get_progress(), enemy.current_state.get_iteration_progress()]
