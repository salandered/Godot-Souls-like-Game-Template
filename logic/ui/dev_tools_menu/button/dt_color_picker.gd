class_name DTColorPicker
extends ColorPicker


@export var key_value_changer: DTS.KeyColorChanger = DTS.KeyColorChanger.UNKNOWN
@export var dv_section: DTS.DTSection = DTS.DTSection.COLOR_CHANGER


func get_dtc_key() -> int:
	return key_value_changer


func _ready():
	SigUtils.safe_connect(color_changed, _on_color_changed)


func _on_color_changed(color_: Color):
	SigUtils.safe_emit(GlobalSignal.SIG_dt_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dtc_value_field: color_,
		SPS.dtc_section_field: dv_section,
		SPS.dtc_key_field: get_dtc_key()
		})
