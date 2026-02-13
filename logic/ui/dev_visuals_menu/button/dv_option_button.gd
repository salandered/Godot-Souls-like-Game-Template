extends OptionButton
class_name DVOptionButton


@export var dv_section: DVS.DVSection = DVS.DVSection.S_CHANGER
@export var key_value_changer: DVS.KeySValueChanger = DVS.KeySValueChanger.UNKNOWN


func get_dvc_key() -> int:
	return key_value_changer


func _ready() -> void:
	## this part specific to DV_SPECTRUM_AUDIO_BUS (should be moved)
	clear()
	var bus_names := AudioServerUtil.get_all_bus_names()
	# print_.dev("DVOptionButton", bus_names)
	for b_name in bus_names:
		add_item(b_name)

	SigUtils.safe_connect(item_selected, _on_item_selected)


func _on_item_selected(index: int):
	var item_text := get_item_text(index)
	
	SigUtils.safe_emit_raw(GlobalSignal.SIG_dv_ui_control_value_changed, {
		SPS.button_name_field: str(name),
		SPS.dvc_value_field: item_text,
		SPS.dvc_section_field: dv_section,
		SPS.dvc_key_field: key_value_changer
	})
