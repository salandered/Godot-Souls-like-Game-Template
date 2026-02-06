class_name AllLogPanelManager
extends BaseTextInfoPanelManager


@onready var all_logs_panel: MarginContainer = %AllLogsPanel
@onready var all_logs_label: RichTextLabel = %AllLogsLabel


func get_max_lines() -> int:
	return 60


func get_ui_panel() -> Container:
	return all_logs_panel


func get_text_label() -> RichTextLabel:
	return all_logs_label


func _supported_signal_pairs() -> Array[Array]:
	return [
		[GlobalSignal.__SIG_all_log_printed, _on___SIG_all_log_printed]
	]


func _on___SIG_all_log_printed(payload: Dictionary[String, Variant]) -> void:
	var _r_frame := SigUtils.safe_get_string_payload_value(payload, SPS.frame_field)
	if _r_frame.err: return
	var _r_msg := SigUtils.safe_get_string_payload_value(payload, SPS.message_field)
	if _r_msg.err: return
	

	var regex_result := _apply_regex_filter(
		[_r_msg.value],
		DVS.DVSection.VALUE_CHANGER,
		DVS.KeyValueChanger.ALL_LOG_FILTER
	)

	if regex_result == RegexFilter.Result.PASS:
		var final_msg := _build_msg(_r_frame.value, _r_msg.value)
		_append_text_to_label(final_msg)
	
	elif regex_result == RegexFilter.Result.ERROR:
		_append_invalid_regex_text_to_label()
	
	
var col_msg := "#e6e6e6"


func _build_msg(frame: String, message: String) -> String:
	var msg_bb := BB.color_wrap(message.strip_edges(), col_msg)

	return pp.s(_log_prefix(frame), msg_bb)
