extends OptionButton
class_name DTOptionButton


@export var dv_section: DTS.DTSection = DTS.DTSection.S_CHANGER
@export var key_value_changer: DTS.KeySValueChanger = DTS.KeySValueChanger.UNKNOWN


func get_dtc_key() -> int:
	return key_value_changer


func _ready() -> void:
	## this part specific to DT_SPECTRUM_AUDIO_BUS (should be moved)
	clear()
	var bus_names := AudioServerUtil.get_all_bus_names()
	for b_name in bus_names:
		add_item(b_name)

	SigUtils.safe_connect(item_selected, _on_item_selected)


func _on_item_selected(index: int):
	var item_text := get_item_text(index)
	
	SigUtils.safe_emit(GlobalSignal.SIG_dt_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dtc_value_field: item_text,
		SPS.dtc_section_field: dv_section,
		SPS.dtc_key_field: key_value_changer
	})
