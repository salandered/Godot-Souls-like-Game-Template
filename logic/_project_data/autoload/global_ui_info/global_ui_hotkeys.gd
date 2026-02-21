@tool
extends BaseInputDevHotkeys

## part of GlobalUIInfo


## NOTE: lots of additional hotkeys added for demo


var mouse_is_captured: bool = true
var sp_scale_step: float = 0.1 * 2


func _unhandled_input_implementation(event: InputEvent) -> void:
	pass

func _input_implementation(event: InputEvent) -> void:
	if not GlobalUIInfo.is_node_ready():
		return

	var _dvc: DevVisualsConfig = GlobalUIInfo.get_dev_visuals_config()
	if not _dvc:
		return

	## CTRL SHIFT
	if InputUtils.is_keycode_w_ctrl_shift(event, KEY_I):
		_dvc.toggle_bvalue_array(
			DVS.DVSection.B_OVERLAY_PANEL,
			[
				DVS.KeyBOverlayPanel.RAW_INPUT,
				DVS.KeyBOverlayPanel.ACTION_INPUT,
				DVS.KeyBOverlayPanel.PLAYER_INPUT_INFO
			]
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_T):
		_dvc.toggle_all_char_dv_options(
			DVS.CharDVType.WEAPON_TRAIL,
		)
		InputUtils.mark_input_handled(self )
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_E, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.ERROR_LOG):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_C, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.PLAYER_COMBO):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_L, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.ALL_LOG):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_R, DVS.DVSection.B_CHANGER, DVS.KeyBValueChanger.PLAYER_ROOT_MOTION_VECTOR):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_N, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.CAM_NODES):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_V, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.SUBVIEWPORT):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_M, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.BUS_SPECTRUM):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dvc, event, KEY_U, DVS.DVSection.B_OVERLAY_PANEL, DVS.KeyBOverlayPanel.ENEMY_ANIMATOR):
		pass
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_K):
		_dvc.toggle_all_char_dv_options(
			DVS.CharDVType.SKELETON_VISUALS
		)
		_dvc.toggle_all_char_dv_options(
			DVS.CharDVType.HIDE_MESH_VISUALS
		)
		_dvc.toggle_bvalue(
			DVS.DVSection.B_CHANGER,
			DVS.KeyBValueChanger.SHOW_BONES_SIMPLIFIED
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_S):
		_dvc.toggle_bvalue_composite_key(
			DVS.DVSection.B_CHAR_DV,
			DVS.CharacterType.PLAYER,
			DVS.CharDVType.STATE_INFO
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_A):
		_dvc.toggle_bvalue_composite_key(
			DVS.DVSection.B_CHAR_DV,
			DVS.CharacterType.PLAYER,
			DVS.CharDVType.ATTACK_INFO
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_H):
		_dvc.toggle_bvalue_composite_key(
			DVS.DVSection.B_CHAR_DV,
			DVS.CharacterType.PLAYER,
			DVS.CharDVType.HIDE_MESH_VISUALS
		)
		InputUtils.mark_input_handled(self )

	## CTRL ALT
	elif _is_keycode_w_ctrl_alt_b_value(_dvc, event, KEY_A, DVS.DVSection.B_CHANGER, DVS.KeyBValueChanger.ALL_AREA3D):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dvc, event, KEY_C, DVS.DVSection.B_CHANGER, DVS.KeyBValueChanger.CHARACTER_COLLIDERS):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dvc, event, KEY_H, DVS.DVSection.B_CHANGER, DVS.KeyBValueChanger.WEAR_HAT):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dvc, event, KEY_T, DVS.DVSection.B_CHANGER, DVS.KeyBValueChanger.ROOT_TRAIL):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dvc, event, KEY_L, DVS.DVSection.B_CHANGER, DVS.KeyBValueChanger.PLAYER_LIGHTS):
		pass

	## CTRL 
	elif InputUtils.is_keycode_w_ctrl(event, KEY_H):
		# _dev_visual_config.toggle_bvalue_array(
		# 	DVS.DVSection.B_CHANGER,
		# 	[
		# 		DVS.KeyBValueChanger.WEAPON_HIT,
		# 	],
		# )
		_dvc.toggle_all_char_dv_options(
			DVS.CharDVType.HITBOX,
		)
		_dvc.toggle_all_char_dv_options(
			DVS.CharDVType.WEAPON_HITBOX,
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl(event, KEY_I):
		_dvc.toggle_bvalue(
			DVS.DVSection.B_OVERLAY_PANEL,
			DVS.KeyBOverlayPanel.RAW_INPUT,
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl(event, KEY_U):
		_dvc.toggle_bvalue(
			DVS.DVSection.B_OVERLAY_PANEL,
			DVS.KeyBOverlayPanel.PLAYER_SK_ANIMATOR,
		)
		InputUtils.mark_input_handled(self )

	## NO MOD
	elif InputUtils.is_keycode(event, KEY_KP_3):
		_toggle_mouse_capture()
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode(event, KEY_KP_ADD):
		_add_fvalue_sp_scale(_dvc)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode(event, KEY_KP_SUBTRACT):
		_add_fvalue_sp_scale(_dvc, -1)
		InputUtils.mark_input_handled(self )


func _is_keycode_w_ctrl_shift_b_value(_dvc: DevVisualsConfig, event: InputEvent, code: int, section: DVS.DVSection, key: int) -> bool:
	if InputUtils.is_keycode_w_ctrl_shift(event, code):
		_dvc.toggle_bvalue(
			section,
			key
		)
		InputUtils.mark_input_handled(self )
		return true
	return false


func _is_keycode_w_ctrl_alt_b_value(_dvc: DevVisualsConfig, event: InputEvent, code: int, section: DVS.DVSection, key: int) -> bool:
	if InputUtils.is_keycode_w_ctrl_alt(event, code):
		_dvc.toggle_bvalue(
			section,
			key
		)
		InputUtils.mark_input_handled(self )
		return true
	return false


func _toggle_mouse_capture():
	print_.dev("mouse_mode_switch")
	if mouse_is_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	mouse_is_captured = not mouse_is_captured
	

func _add_fvalue_sp_scale(_dvc: DevVisualsConfig, mult: int = 1):
	_dvc.add_fvalue(
		DVS.DVSection.F_CHANGER,
		DVS.KeyFValueChanger.PL_SPEED_SCALE,
		sp_scale_step * mult
		)
	_dvc.add_fvalue(
		DVS.DVSection.F_CHANGER,
		DVS.KeyFValueChanger.HSM_SPEED_SCALE,
		sp_scale_step * mult
	)
	_dvc.add_fvalue(
		DVS.DVSection.F_CHANGER,
		DVS.KeyFValueChanger.SE_SPEED_SCALE,
		sp_scale_step * mult
	)
