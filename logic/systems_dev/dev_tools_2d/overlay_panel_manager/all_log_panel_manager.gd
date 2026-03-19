@tool
class_name AllLogPanelManager
extends BaseTextInfoPanelManager

@onready var logs_panel: LogsUIPanel = %LogsPanel

const COL_MSG := "#e6e6e6"


func get_max_lines() -> int:
	return 60


func get_ui_panel() -> Container:
	return logs_panel.all_logs_panel if logs_panel else null


func get_text_label() -> RichTextLabel:
	return logs_panel.all_logs_label if logs_panel else null


func get_dtc_op_key() -> DTS.KeyBOverlayPanel:
	return DTS.KeyBOverlayPanel.ALL_LOG


func _supported_signal_pairs() -> Array[Array]:
	return [
		[GlobalSignal.__SIG_all_log_printed, _on___SIG_all_log_printed]
	]


func _on___SIG_all_log_printed(payload: Dictionary[StringName, Variant]) -> void:
	var _r_frame := SigUtils.safe_get_string_payload_value(payload, SPS.frame_field)
	if _r_frame.err: return
	var _r_msg := SigUtils.safe_get_string_payload_value(payload, SPS.message_field)
	if _r_msg.err: return

	var regex_result := _apply_regex_filter(
		[_r_msg.value],
		DTS.DTSection.S_CHANGER,
		DTS.KeySValueChanger.ALL_LOG_FILTER
	)

	if regex_result == RegexFilter.Result.PASS:
		var final_msg := _build_msg(_r_frame.value, _r_msg.value)
		_append_text_to_label(final_msg)
	
	elif regex_result == RegexFilter.Result.ERROR:
		_append_invalid_regex_text_to_label()
	
	
func _build_msg(frame: String, message: String) -> String:
	var msg_bb := BB.color_wrap(message.strip_edges(), COL_MSG)

	return pp.s(_log_prefix(frame), msg_bb)
