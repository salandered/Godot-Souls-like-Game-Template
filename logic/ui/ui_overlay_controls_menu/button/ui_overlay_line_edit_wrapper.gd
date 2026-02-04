extends Node


var _parent: UIOverlayLineEdit


func _ready() -> void:
	var parent = get_parent()
	if parent is UIOverlayLineEdit:
		_parent = parent
		SigUtils.safe_connect(_parent.text_changed, _on_parent_text_changed)


func _on_parent_text_changed(new_text: String):
	if _parent:
		SigUtils.safe_emit_raw(GlobalSignal.SIG_ui_overlay_control_value_changed, {
			SPS.value_field: new_text,
			SPS.button_name_field: str(_parent.name),
			SPS.dvc_value_type_field: _parent.overlay_value_type,
			})
