@abstract
class_name BaseTextInfoPanelManager
extends NodeSystem


var _regex_filter := RegexFilter.new()


func __hard_validation() -> bool:
	if not get_ui_panel():
		return false
	if not get_text_label():
		return false
	return true


func _ready() -> void:
	if not __perform_validation():
		__log_warn_soft("won't be working")
	else:
		get_text_label().text = ""
		_ready_imp()


func _ready_imp():
	pass


@abstract func get_max_lines() -> int


@abstract func get_ui_panel() -> Container

@abstract func get_text_label() -> RichTextLabel


@abstract func _supported_signal_pairs() -> Array[Array]


func _append_text_to_label(bb_text: String) -> void:
	if not get_text_label():
		return
		
	get_text_label().append_text(bb_text)
	_trim_log()


func _trim_log() -> void:
	var total_lines := get_text_label().get_paragraph_count()
	var lines_to_remove := total_lines - get_max_lines()
	# __log_("total_lines", total_lines, "lines_to_remove", lines_to_remove)
	if lines_to_remove > 0:
		# always remove index 0 because the indices shift up after every removal
		for i in range(lines_to_remove):
			get_text_label().remove_paragraph(0)


func set_enable(value: bool):
	if not __validation_ok():
		__log_warn_soft("validation failed, can't be enabled")
		return

	__log_("set_enabled", value)

	if get_ui_panel():
		get_ui_panel().visible = value

	var pairs := _supported_signal_pairs()
	if value:
		SigUtils.safe_connect_pairs(pairs)
	else:
		SigUtils.safe_disconnect_pairs(pairs)
