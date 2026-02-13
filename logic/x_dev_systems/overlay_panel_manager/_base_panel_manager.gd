@tool

@abstract
class_name BasePanelManager
extends BaseDVCDependentNode


func __hard_validation() -> bool:
	if not get_ui_panel():
		return false
	return true


func initialise() -> void:
	if Engine.is_editor_hint(): return

	reset_visuals()

		
	await FrameUtils.wait_process_frames(4)
	initialise_implementation()
	
	
	if not __perform_validation(true):
		__log_warn_soft("won't be working")
	else:
		set_enabled(false)
		SigUtils.safe_connect(GlobalUIInfo.SIG_dvc_b_overlay_panel_value_changed, _enable_via_sig)


## called before validation
func initialise_implementation():
	pass


func reset_visuals() -> void:
	if Engine.is_editor_hint(): return
	if get_ui_panel():
		get_ui_panel().visible = false


@abstract func get_ui_panel() -> Container


@abstract func _supported_signal_pairs() -> Array[Array]


@abstract func get_dvc_op_key() -> DVS.KeyBOverlayPanel


func _enable_via_sig(payload: Dictionary[String, Variant]) -> void:
	var _r := DVCSIGPayloadParser.safe_bget_value_by_dvc_key(
		payload,
		get_dvc_op_key()
		)
	if _r.err: return
	
	set_enabled(_r.value)


func set_enabled(value: bool):
	if not __validation_ok():
		__log_warn_soft("validation failed, can't be enabled")
		return

	__log_("set_enabled", value)

	if get_ui_panel():
		get_ui_panel().visible = value

	var pairs := _supported_signal_pairs()
	if value:
		SigUtils.safe_connect_pairs(pairs)
	else:
		SigUtils.safe_disconnect_pairs(pairs)


func is_panel_visible() -> bool:
	if not __validation_ok():
		return false
	
	if not get_ui_panel():
		return false
		
	return get_ui_panel().visible
