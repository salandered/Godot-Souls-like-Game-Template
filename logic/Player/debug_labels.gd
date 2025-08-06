extends Node


@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var player: Princess = $".."

func _dev_player_info():
	var p_pos = player.model.global_position
	var nest_pos := player.fancy_camera.nest.global_position
	var camera_pos := player.fancy_camera.camera.global_position
	
	
	label.text = "player to nest " + "%10.3f" % p_pos.distance_to(nest_pos)
	label.text += "\n player to cam " + "%10.3f" % p_pos.distance_to(camera_pos)

	var free_offset = player.fancy_camera.free_camera.offset.length() if player.fancy_camera.free_camera.offset else 0.0
	var locked_offset := player.fancy_camera.locked_camera.offset.length() if player.fancy_camera.locked_camera.offset else 0.0
	label_2.text = "offset " + "%10.3f" % free_offset
	label_2.text += "\n %10.3f" % locked_offset

func _dev_enemy_info(enemy: SECharacter):
	var e_pos = enemy.global_position
	var p_pos = player.model.global_position
	label_3.text = "enemy to pl " + "%5.1f" % e_pos.distance_to(p_pos)
	label_3.text += "\n st-time %7.3f %7.3f" % [enemy.current_state.get_progress(), enemy.current_state.get_iteration_progress()]
