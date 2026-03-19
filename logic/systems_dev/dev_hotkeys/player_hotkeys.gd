@tool
extends BaseInputDevHotkeys


var __collisions_enabled: bool = true

@export var _player: Princess


func _unhandled_input_implementation(event: InputEvent) -> void:
	if not _player:
		return
	
	## COLLISION
	if event.is_action_pressed(RawAction.DEV_cols):
		__collisions_enabled = not __collisions_enabled
		if __collisions_enabled:
			_player.collision_mask = Collision.Masks.PLAYER_COL_MASK
		else:
			_player.collision_mask = Collision.Masks._ZERO_MASK


	## COMBAT
	if not _player.get_combat():
		return
	if InputUtils.is_keycode_w_ctrl(event, KEY_J):
		var hit := HitData.new(25, "from god", PHEA.attack.sword_slide, 1.0, "test attack", AttackDirection.Dir.LEFT)
		_player.get_combat()._last_processed_hit = hit
		_player.react_on_hit(hit)
	if InputUtils.is_keycode_w_ctrl(event, KEY_K):
		var hit := HitData.new(24, "from god", PHEA.attack.attack_360_low, 1.0, "test attack", AttackDirection.Dir.RIGHT)
		_player.get_combat()._last_processed_hit = hit
		_player.react_on_hit(hit)
	if InputUtils.is_keycode_w_ctrl(event, KEY_L):
		var hit := HitData.new(24, "from god", PHEA.attack.attack_up, 1.0, "test attack", AttackDirection.Dir.UP)
		_player.get_combat()._last_processed_hit = hit
		_player.react_on_hit(hit)

	
	## OVERLAY
	# if event.is_action_pressed(RawAction.DEV_8):
	# 	animator_manager.set_overlay_anim(A.react.react_from_L,
	# 	OverlayConfig.new(
	# 		OverlayConfig.Weight.new(0.8, 0.4),
	# 		BlendConfig.new(),
	# 		1.0,
	# 		BoneMask.get_upper_body_with_hips()
	# 		))


func _input_implementation(event: InputEvent) -> void:
	pass


# region: DEV CAMERAS

	# if event.is_action_pressed(RawAction.DEV_CAM_cycle):
	# 	cam_i = (cam_i + 1) % debug_cams.size()
	# 	print_.dev("dbg", "cam_i: " + str(cam_i))
	# 	if debug_cams[cam_i].has_method("make_current"):
	# 		debug_cams[cam_i].make_current()

	# elif event.is_action_pressed(RawAction.DEV_CAM_cycle_prev):
	# 	cam_i = (cam_i - 1 + debug_cams.size()) % debug_cams.size()
	# 	print_.dev("dbg", "cam_i: " + str(cam_i))
	# 	if debug_cams[cam_i].has_method("make_current"):
	# 		debug_cams[cam_i].make_current()

	# var debug_cams: Array[Node]
	# var cam_i := 0
	# func __dev_initialize():
	# 	if eu.is_release():
	# 		return
	# 	debug_cams = get_tree().get_nodes_in_group(Groups.Dev.DEBUG_CAMERAS)
	# 	debug_cams.append(fancy_camera.camera)
	# 	cam_i = len(debug_cams) - 1

# endregion
