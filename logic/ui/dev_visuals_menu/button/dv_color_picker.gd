class_name DVColorPicker
extends ColorPicker


@export var key_value_changer: DVS.KeyColorChanger = DVS.KeyColorChanger.UNKNOWN
@export var dv_section: DVS.DVSection = DVS.DVSection.COLOR_CHANGER


func get_dvc_key() -> int:
	return key_value_changer


func _ready():
	SigUtils.safe_connect(color_changed, _on_color_changed)


func _on_color_changed(color_: Color):
	SigUtils.safe_emit_raw(GlobalSignal.SIG_dv_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dvc_value_field: color_,
		SPS.dvc_section_field: dv_section,
		SPS.dvc_key_field: get_dvc_key()
		})
