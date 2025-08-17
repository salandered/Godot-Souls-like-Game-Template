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
	
	
	label.text = "player to nest " + "%10.3f" % p_pos.distance_to(nest_pos)
	label.text += "\n player to cam " + "%10.3f" % p_pos.distance_to(camera_pos)

	var free_offset = player.fancy_camera.free_camera.offset.length() if player.fancy_camera.free_camera.offset else 0.0
	var locked_offset := player.fancy_camera.locked_camera.offset.length() if player.fancy_camera.locked_camera.offset else 0.0
	label_2.text = "offset " + "%10.3f" % free_offset
	label_2.text += "\n %10.3f" % locked_offset


func _label_state_info():
	var c_s := player.model.player_sm.current_state
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

func _label_sk_m_info():
	var full_body_a := player.model.full_body
	var torso_a := player.model.torso
	var legs_a := player.model.legs_animator

	label_4.text = __sk_m_label(full_body_a)
	label_5.text = __sk_m_label(torso_a)
	label_6.text = __sk_m_label(legs_a)


func __sk_m_label(animator: SimpleAnimator_):
	var text = ""
	text += (animator.current_animation.resource_name if animator.current_animation else "-None-")
	text += "\n %5.2f" % [animator.current_animation_progress]
	text += "  l:" + str(animator.current_animation_cycling)

	if animator.is_blending:
		text += "\nb" + "%5.1f" % (animator.blending_percentage * 100) + "%"
		text += " " + "%7.2f" % animator.blend_time_spent + "/" + "%7.2f" % animator.blend_duration
		text += "\n from: " + (animator.previous_animation.resource_name if animator.previous_animation else "-None-")

	return text

# FROM OUTSIDE THE PLAYER

func _label_enemy_info(enemy: SECharacter):
	var e_pos = enemy.global_position
	var p_pos = player.model.global_position
	label_3.text = "enemy to pl " + "%5.1f" % e_pos.distance_to(p_pos)
	label_3.text += "\n st-time %7.3f %7.3f" % [enemy.current_state.get_progress(), enemy.current_state.get_iteration_progress()]
