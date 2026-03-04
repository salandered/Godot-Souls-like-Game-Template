@abstract
class_name BaseDVSettingCheckButton
extends CheckButton


@export var dv_section: DTS.DTSection = DTS.DTSection.B_CHANGER

@export var tied_toggle_buttons: Array[BaseDVSettingCheckButton] = []


func _ready():
	SigUtils.safe_connect(toggled, _on_toggled)

	for item: BaseDVSettingCheckButton in tied_toggle_buttons:
		SigUtils.safe_connect(item.toggled, _on_tied_button_toggled)


@abstract func get_dtc_key() -> int


func _on_toggled(toggle: bool):
	SigUtils.safe_emit(GlobalSignal.SIG_dt_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		## here deliberately using value_field (not toggle_field)
		SPS.dtc_value_field: toggle,
		SPS.dtc_section_field: dv_section,
		SPS.dtc_key_field: get_dtc_key()
		})


func _on_tied_button_toggled(toggle: bool):
	set_pressed_no_signal(toggle)
	_on_toggled(toggle)


## 

func __LOG_B() -> bool:
	return true
