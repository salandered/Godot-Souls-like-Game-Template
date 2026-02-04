class_name SigInfoManager
extends BaseTextInfoPanelManager


@onready var signal_info_panel: MarginContainer = %SignalInfoPanel
@onready var sig_info_label: RichTextLabel = %SigInfoLabel


func get_max_lines() -> int:
	return 50


func get_ui_panel() -> Container:
	return signal_info_panel

func get_text_label() -> RichTextLabel:
	return sig_info_label


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.__SIG_sig_emitted, _on___SIG_emitted],

	]
	return sig_to_handler


## filter signals which are used for SigInfoManager to work 
func _filter_self_signals(sig_name: String, payload: Dictionary[String, Variant]) -> bool:
	if sig_name == GlobalSignal.SIG_ui_overlay_control_value_changed.get_name():
		var _r_type := SigUtils.safe_get_int_payload_value(payload, SPS.dvc_value_type_field)
		if _r_type.err: return false
		if _r_type.value == DevVisualsConfig.ValueType.SIG_FILTER:
			return true
	elif sig_name == GlobalUIInfo.SIG_dvc_value_changed.get_name():
		var parsed_payload := SigUtils.safe_get_SIG_dvc_value_changed_payload(payload)
		if not parsed_payload: return false
		if parsed_payload.value_type == DevVisualsConfig.ValueType.SIG_FILTER:
			return true
	return false


func _on___SIG_emitted(__payload: Dictionary[String, Variant]):
	var _r_name := SigUtils.safe_get_string_payload_value(__payload, SPS.sig_name_field)
	if _r_name.err: return
	var _r_w_p := SigUtils.safe_get_bool_payload_value(__payload, SPS.sig_with_payload_field)
	if _r_w_p.err: return
	var with_payload := _r_w_p.value

	var payload: Dictionary[String, Variant] = {}
	if with_payload:
		var _r_p := SigUtils.safe_get_dict_payload_value(__payload, SPS.sig_payload_field)
		if _r_p.err: return
		payload = TypeCast.dict_string_variant(_r_p.value)

	if _filter_self_signals(_r_name.value, payload):
		return

	var sig_name_str: String = _r_name.value
	var payload_str: String = pp.dict_flat_perfomant(payload)
	
	var raw_content_for_filter := sig_name_str + " " + payload_str

	var filter_text := ""
	var dvc = GlobalUIInfo.get_dev_visuals_config()
	if dvc:
		filter_text = dvc.sget_value(DevVisualsConfig.ValueType.SIG_FILTER)

	var regex_r := _regex_filter.apply_filter(raw_content_for_filter, filter_text)

	if regex_r == RegexFilter.Result.PASS:
		# fancy BBCode message if it survived the filter
		var final_msg := _build_msg(sig_name_str, payload_str)
		_append_text_to_label(final_msg)
		
	elif regex_r == RegexFilter.Result.ERROR:
		var err_msg := BB.color_wrap(BB.i_wrap("invalid regex"), "#ff868bff")
		_append_text_to_label(err_msg)


func _build_msg(sig_name: String, payload_str: String) -> String:
	var col_time := "#888888"
	var col_sig := "#8b93ffff"
	var col_payload := "#d3d3d3ff"

	var time_bb := BB.color_wrap(u.get_time_string_from_system_mm_ss(), col_time)
	var name_bb := BB.color_wrap(sig_name, col_sig)
	
	var load_bb := BB.color_wrap(BB.i_wrap("\t" + payload_str), col_payload)

	return pp.s(
		time_bb, " ", name_bb, "\n",
		load_bb, "\n"
	)
