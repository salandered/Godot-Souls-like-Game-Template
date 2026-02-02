extends Node


var _parent: UIOverlaySpinBox


func _ready() -> void:
	var parent = get_parent()
	if parent is UIOverlaySpinBox:
		_parent = parent
		SigUtils.safe_connect(_parent.value_changed, _on_parent_value_changed)


func _on_parent_value_changed(value: float):
	if _parent:
		SigUtils.safe_emit_raw(GlobalSignal.SIG_ui_overlay_spin_box_value_changed, {
			SPS.value_field: value,
			SPS.button_name_field: str(_parent.name),
			SPS.type_field: _parent.overlay_value_type,

			})
