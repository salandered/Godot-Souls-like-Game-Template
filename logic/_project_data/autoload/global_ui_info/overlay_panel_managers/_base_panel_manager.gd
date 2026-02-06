@abstract
class_name BasePanelManager
extends NodeSystem


func __hard_validation() -> bool:
	if not get_ui_panel():
		return false
	return true


func _ready() -> void:
	if not __perform_validation():
		__log_warn_soft("won't be working")
	else:
		_ready_imp()
		set_enable(false)
		if _get_enabler_sig() is Signal:
			SigUtils.safe_connect(_get_enabler_sig() as Signal, _enable_via_sig)


func _ready_imp():
	pass


@abstract func get_ui_panel() -> Container


@abstract func _supported_signal_pairs() -> Array[Array]


func _get_enabler_sig() -> Variant:
	return null


func _parse_enabler_sig(payload: Dictionary[String, Variant]) -> RO.BoolReturn:
	return null


func _enable_via_sig(payload: Dictionary[String, Variant]) -> void:
	var r_toggle := _parse_enabler_sig(payload)
	if r_toggle and not r_toggle.err:
		set_enable(r_toggle.value)


func set_enable(value: bool):
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
