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
	if sig_name == GlobalUIInfo.SIG_dvc_value_changed_section_vc.get_name():
		var parsed_payload := SigPayloadParser.safe_get_SIG_dvc_value_changed_section_payload(payload)
		if not parsed_payload: return false
		if parsed_payload.key == DVS.KeyValueChanger.SIG_FILTER:
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

	var _r_frame := SigUtils.safe_get_string_payload_value(__payload, SPS.frame_field)
	if _r_frame.err: return

	if _filter_self_signals(_r_name.value, payload):
		return

	var sig_name_str: String = _r_name.value
	var payload_str: String = pp.dict_flat_perfomant(payload)
	
	var regex_result := _apply_regex_filter(
		[sig_name_str, payload_str],
		DVS.DVSection.VALUE_CHANGER,
		DVS.KeyValueChanger.SIG_FILTER
	)

	if regex_result == RegexFilter.Result.PASS:
		# BBCode message if it survived the filter
		var final_msg := _build_msg(_r_frame.value, sig_name_str, payload_str)
		_append_text_to_label(final_msg)
	
	elif regex_result == RegexFilter.Result.ERROR:
		_append_invalid_regex_text_to_label()


var col_sig := "#8b93ffff"
var col_payload := "#d3d3d3ff"


func _build_msg(frame: String, sig_name: String, payload_str: String) -> String:
	var name_bb := BB.color_wrap(sig_name, col_sig)
	var load_bb := BB.color_wrap(BB.i_wrap("\t" + payload_str), col_payload)

	return pp.s(_log_prefix(frame),
		name_bb, "\n",
		load_bb
	)
