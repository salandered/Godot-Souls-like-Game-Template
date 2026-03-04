class_name DTValueChangerSpinBox
extends SpinBox


@export var dv_section: DTS.DTSection = DTS.DTSection.F_CHANGER
@export var key_value_changer: DTS.KeyFValueChanger = DTS.KeyFValueChanger.UNKNOWN


func _ready():
	SigUtils.safe_connect(value_changed, _on_value_changed)


func get_dtc_key() -> int:
	return key_value_changer


func _on_value_changed(value_: float):
	SigUtils.safe_emit(GlobalSignal.SIG_dt_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dtc_value_field: value_,
		SPS.dtc_section_field: dv_section,
		SPS.dtc_key_field: key_value_changer
		})
