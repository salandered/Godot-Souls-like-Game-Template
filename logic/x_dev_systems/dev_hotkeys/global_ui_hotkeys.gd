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

	var _dtc: DevVisualsConfig = GlobalUIInfo.get_dev_tools_config()
	if not _dtc:
		return

	## CTRL SHIFT
	if InputUtils.is_keycode_w_ctrl_shift(event, KEY_I):
		_dtc.toggle_bvalue_array(
			DTS.DTSection.B_OVERLAY_PANEL,
			[
				DTS.KeyBOverlayPanel.RAW_INPUT,
				DTS.KeyBOverlayPanel.ACTION_INPUT,
				DTS.KeyBOverlayPanel.PLAYER_INPUT_INFO
			]
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_T):
		_dtc.toggle_all_char_dv_options(
			DTS.CharDVType.WEAPON_TRAIL,
		)
		InputUtils.mark_input_handled(self )
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_E, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.ERROR_LOG):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_C, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.PLAYER_COMBO):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_L, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.ALL_LOG):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_R, DTS.DTSection.B_CHANGER, DTS.KeyBValueChanger.PLAYER_ROOT_MOTION_VECTOR):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_N, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.CAM_NODES):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_V, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.SUBVIEWPORT):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_M, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.BUS_SPECTRUM):
		pass
	elif _is_keycode_w_ctrl_shift_b_value(_dtc, event, KEY_U, DTS.DTSection.B_OVERLAY_PANEL, DTS.KeyBOverlayPanel.ENEMY_ANIMATOR):
		pass
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_K):
		_dtc.toggle_all_char_dv_options(
			DTS.CharDVType.SKELETON_VISUALS
		)
		_dtc.toggle_all_char_dv_options(
			DTS.CharDVType.HIDE_MESH_VISUALS
		)
		_dtc.toggle_bvalue(
			DTS.DTSection.B_CHANGER,
			DTS.KeyBValueChanger.SHOW_BONES_SIMPLIFIED
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_S):
		_dtc.toggle_bvalue_composite_key(
			DTS.DTSection.B_CHAR_DV,
			DTS.CharacterType.PLAYER,
			DTS.CharDVType.STATE_INFO
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_A):
		_dtc.toggle_bvalue_composite_key(
			DTS.DTSection.B_CHAR_DV,
			DTS.CharacterType.PLAYER,
			DTS.CharDVType.ATTACK_INFO
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl_shift(event, KEY_H):
		_dtc.toggle_bvalue_composite_key(
			DTS.DTSection.B_CHAR_DV,
			DTS.CharacterType.PLAYER,
			DTS.CharDVType.HIDE_MESH_VISUALS
		)
		InputUtils.mark_input_handled(self )

	## CTRL ALT
	elif _is_keycode_w_ctrl_alt_b_value(_dtc, event, KEY_A, DTS.DTSection.B_CHANGER, DTS.KeyBValueChanger.ALL_AREA3D):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dtc, event, KEY_C, DTS.DTSection.B_CHANGER, DTS.KeyBValueChanger.CHARACTER_COLLIDERS):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dtc, event, KEY_H, DTS.DTSection.B_CHANGER, DTS.KeyBValueChanger.WEAR_HAT):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dtc, event, KEY_T, DTS.DTSection.B_CHANGER, DTS.KeyBValueChanger.ROOT_TRAIL):
		pass
	elif _is_keycode_w_ctrl_alt_b_value(_dtc, event, KEY_L, DTS.DTSection.B_CHANGER, DTS.KeyBValueChanger.PLAYER_LIGHTS):
		pass

	## CTRL 
	elif InputUtils.is_keycode_w_ctrl(event, KEY_H):
		# _dev_visual_config.toggle_bvalue_array(
		# 	DTS.DVSection.B_CHANGER,
		# 	[
		# 		DTS.KeyBValueChanger.WEAPON_HIT,
		# 	],
		# )
		_dtc.toggle_all_char_dv_options(
			DTS.CharDVType.HITBOX,
		)
		_dtc.toggle_all_char_dv_options(
			DTS.CharDVType.WEAPON_HITBOX,
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl(event, KEY_I):
		_dtc.toggle_bvalue(
			DTS.DTSection.B_OVERLAY_PANEL,
			DTS.KeyBOverlayPanel.RAW_INPUT,
		)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode_w_ctrl(event, KEY_U):
		_dtc.toggle_bvalue(
			DTS.DTSection.B_OVERLAY_PANEL,
			DTS.KeyBOverlayPanel.PLAYER_SK_ANIMATOR,
		)
		InputUtils.mark_input_handled(self )

	## NO MOD
	elif InputUtils.is_keycode(event, KEY_KP_3):
		_toggle_mouse_capture()
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode(event, KEY_KP_ADD):
		_add_fvalue_sp_scale(_dtc)
		InputUtils.mark_input_handled(self )
	elif InputUtils.is_keycode(event, KEY_KP_SUBTRACT):
		_add_fvalue_sp_scale(_dtc, -1)
		InputUtils.mark_input_handled(self )


func _is_keycode_w_ctrl_shift_b_value(_dtc: DevVisualsConfig, event: InputEvent, code: int, section: DTS.DTSection, key: int) -> bool:
	if InputUtils.is_keycode_w_ctrl_shift(event, code):
		_dtc.toggle_bvalue(
			section,
			key
		)
		InputUtils.mark_input_handled(self )
		return true
	return false


func _is_keycode_w_ctrl_alt_b_value(_dtc: DevVisualsConfig, event: InputEvent, code: int, section: DTS.DTSection, key: int) -> bool:
	if InputUtils.is_keycode_w_ctrl_alt(event, code):
		_dtc.toggle_bvalue(
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
	

func _add_fvalue_sp_scale(_dtc: DevVisualsConfig, mult: int = 1):
	_dtc.add_fvalue(
		DTS.DTSection.F_CHANGER,
		DTS.KeyFValueChanger.PL_SPEED_SCALE,
		sp_scale_step * mult
		)
	_dtc.add_fvalue(
		DTS.DTSection.F_CHANGER,
		DTS.KeyFValueChanger.HSM_SPEED_SCALE,
		sp_scale_step * mult
	)
	_dtc.add_fvalue(
		DTS.DTSection.F_CHANGER,
		DTS.KeyFValueChanger.SE_SPEED_SCALE,
		sp_scale_step * mult
	)
