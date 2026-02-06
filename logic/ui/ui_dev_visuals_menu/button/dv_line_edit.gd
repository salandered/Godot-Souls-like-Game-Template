extends LineEdit
class_name DVLineEdit


@export var dv_section: DVS.DVSection = DVS.DVSection.UNKNOWN
@export var key_value_changer: DVS.KeyValueChanger = DVS.KeyValueChanger.UNKNOWN


func _ready():
	SigUtils.safe_connect(text_changed, _on_text_changed)


func get_dvc_key() -> int:
	return key_value_changer


func _on_text_changed(new_text: String):
	SigUtils.safe_emit_raw(GlobalSignal.SIG_dv_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dvc_value_field: new_text,
		SPS.dvc_section_field: dv_section,
		SPS.dvc_key_field: key_value_changer
		})


func __LOG_B() -> bool:
	return true
