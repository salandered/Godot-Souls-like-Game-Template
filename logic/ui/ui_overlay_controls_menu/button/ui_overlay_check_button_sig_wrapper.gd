extends Node
class_name UIOverlayControlCheckButtonSigWrapper

var _parent: UIOverlayControlCheckButton


func _ready() -> void:
	var parent = get_parent()
	if parent is UIOverlayControlCheckButton:
		_parent = parent
		SigUtils.safe_connect(_parent.toggled, _on_parent_toggled)


func _on_parent_toggled(toggle: bool):
	if _parent:
		SigUtils.safe_emit_raw(GlobalSignal.SIG_ui_overlay_check_button_toggled, {
			SPS.toggle_field: toggle,
			SPS.button_name_field: str(_parent.name),
			SPS.dvc_value_type_field: _parent.dv_value_type
			})
