class_name DVValueChangerSpinBox
extends SpinBox


@export var dv_section: DVS.DVSection = DVS.DVSection.F_CHANGER
@export var key_value_changer: DVS.KeyFValueChanger = DVS.KeyFValueChanger.UNKNOWN


func _ready():
	SigUtils.safe_connect(value_changed, _on_value_changed)


func get_dvc_key() -> int:
	return key_value_changer


func _on_value_changed(value_: float):
	SigUtils.safe_emit(GlobalSignal.SIG_dv_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dvc_value_field: value_,
		SPS.dvc_section_field: dv_section,
		SPS.dvc_key_field: key_value_changer
		})
