extends LineEdit
class_name DTLineEdit


@export var dv_section: DTS.DTSection = DTS.DTSection.S_CHANGER
@export var key_value_changer: DTS.KeySValueChanger = DTS.KeySValueChanger.UNKNOWN


func _ready():
	SigUtils.safe_connect(text_changed, _on_text_changed)


func get_dtc_key() -> int:
	return key_value_changer


func _on_text_changed(new_text: String):
	SigUtils.safe_emit(GlobalSignal.SIG_dt_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dtc_value_field: new_text,
		SPS.dtc_section_field: dv_section,
		SPS.dtc_key_field: key_value_changer
		})
