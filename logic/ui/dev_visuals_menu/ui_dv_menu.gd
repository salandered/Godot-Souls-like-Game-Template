class_name UIDVMenu
extends PanelContainerSystem


## presets
@onready var all_on: CheckButton = %AllOn
@onready var all_off: CheckButton = %AllOff

##
var dv_setting_check_buttons: Array[BaseDVSettingCheckButton]
var dv_vc_spinboxes: Array[DVValueChangerSpinBox]
var dv_line_edit_array: Array[DVLineEdit]
var dv_option_buttons: Array[DVOptionButton]


func __soft_validation() -> bool:
	for item in dv_setting_check_buttons:
		if item.dv_section == DVS.DVSection.UNKNOWN:
			__log_warn_soft("UNKNOWN section", item.name)
		if item.get_dvc_key() == 0:
			__log_warn_soft("zero dvc key", item.name)
		if item is DVCharDVToggleButton:
			var casted: DVCharDVToggleButton = item
			if casted.key_char_t == DVS.CharacterType.UNKNOWN:
				__log_warn_soft("unknown key_char_t", casted.name)
				return false
			if casted.key_char_dvt == DVS.CharDVType.UNKNOWN:
				__log_warn_soft("unknown key_char_dvt", casted.name)
				return false
	return true


func _ready() -> void:
	SigUtils.safe_connect_pairs([
		[GlobalSignal.SIG_dv_ui_control_value_changed, _on_SIG_dv_ui_control_value_changed],
		[all_on.pressed, _on_SIG_all_on_pressed],
		[all_off.pressed, _on_SIG_all_off_pressed],
	])

	dv_setting_check_buttons = get_descendants.base_dv_setting_check_button(self )
	dv_vc_spinboxes = get_descendants.dv_vc_spinbox(self )
	dv_line_edit_array = get_descendants.dv_line_edit(self )
	dv_option_buttons = get_descendants.dv_option_button(self )

	_set_controls_from_dvc()

	__perform_validation()


func _set_controls_from_dvc():
	var dvc := GlobalUIInfo.get_dev_visuals_config()

	for item in dv_setting_check_buttons:
		if not item:
			error_.warn("null item in dv_setting_check_buttons", "", "", WL.WARN)
			continue
		item.set_pressed_no_signal(dvc.bget_value(item.dv_section, item.get_dvc_key()))

	for item in dv_vc_spinboxes:
		if not item:
			error_.warn("null item in dv_vc_spinboxes", "", "", WL.WARN)
			continue
		item.set_value_no_signal(dvc.fget_value(item.dv_section, item.get_dvc_key()))

	for item in dv_line_edit_array:
		if not item:
			error_.warn("null item in dv_line_edit_array", "", "", WL.WARN)
			continue
		## NOTE: "changing text using this property won't emit the text_changed signal"
		item.text = dvc.sget_value(item.dv_section, item.get_dvc_key())
		
	for item in dv_option_buttons:
		if not item:
			error_.warn("null item in dv_option_buttons", "", "", WL.WARN)
			continue
		## NOTE: "changing text using this property won't emit the text_changed signal"
		var value := dvc.sget_value(item.dv_section, item.get_dvc_key())
		_option_button_select_item_by_text(item, value)


func _option_button_select_item_by_text(opt: OptionButton, text_value: String) -> void:
	for i in opt.item_count:
		if opt.get_item_text(i) == text_value:
			opt.selected = i
			return

	
func _on_SIG_dv_ui_control_value_changed(payload: Dictionary[StringName, Variant]):
	var parsed_payload := DVCSIGPayloadParser.parse_dvc_ui_control_value_changed(payload)
	if not parsed_payload: return

	var dvc := GlobalUIInfo.get_dev_visuals_config()
	__log_(parsed_payload.section, parsed_payload.key, parsed_payload.value)
	dvc.set_value(parsed_payload.section, parsed_payload.key, parsed_payload.value)


func _on_SIG_all_on_pressed():
	for item in dv_setting_check_buttons:
		if item is DVCharDVToggleButton:
			item.button_pressed = true


func _on_SIG_all_off_pressed():
	for item in dv_setting_check_buttons:
		if item is DVCharDVToggleButton:
			item.button_pressed = false

##


func __LOG_B() -> bool:
	return false
