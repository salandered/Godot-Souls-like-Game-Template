class_name ErrorLogPanelManager
extends BaseTextInfoPanelManager


@onready var error_logs_panel: MarginContainer = %ErrorLogsPanel
@onready var error_logs_label: RichTextLabel = %ErrorLogsLabel


func get_max_lines() -> int:
	return 60


func get_ui_panel() -> Container:
	return error_logs_panel


func get_text_label() -> RichTextLabel:
	return error_logs_label


func _supported_signal_pairs() -> Array[Array]:
	return [
		[GlobalSignal.__SIG_error_log_printed, _on___SIG_error_log_printed]
	]


func _on___SIG_error_log_printed(payload: Dictionary[String, Variant]) -> void:
	var _r_frame := SigUtils.safe_get_string_payload_value(payload, SPS.frame_field)
	if _r_frame.err: return
	var _r_msg := SigUtils.safe_get_string_payload_value(payload, SPS.message_field)
	if _r_msg.err: return
	
	var final_msg := _build_msg(_r_frame.value, _r_msg.value)
	
	_append_text_to_label(final_msg)


func _build_msg(frame: String, message: String) -> String:
	var col_time := "#888888"
	var col_frame := "#ffbd2e"
	var col_msg := "#ff868b"

	var time_bb := BB.color_wrap(u.get_time_string_from_system_mm_ss(), col_time)
	var frame_bb := BB.color_wrap(frame, col_frame)
	var msg_bb := BB.color_wrap(message, col_msg)

	return pp.s(
		time_bb, " ", "[", frame_bb, "] ", msg_bb, "\n"
	)
