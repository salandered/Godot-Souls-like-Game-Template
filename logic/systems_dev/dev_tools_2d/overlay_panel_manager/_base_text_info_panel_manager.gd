@tool

@abstract
class_name BaseTextInfoPanelManager
extends BasePanelManager


var _regex_filter := RegexFilter.new()


const COL_TIME := "#888888"
const COL_FRAME := "#5bac7ae3"
const COL_META_ERR := "#ff868bff"

var INVALID_REGEX_TEXT := BB.color_wrap(BB.i_wrap("invalid regex"), COL_META_ERR)


func __hard_validation() -> bool:
	var _r = super.__hard_validation()
	if not get_text_label():
		return false
	return _r


func initialize_implementation():
	if get_text_label():
		get_text_label().text = ""


@abstract func get_max_lines() -> int


@abstract func get_text_label() -> RichTextLabel


## should be called
func _append_text_to_label(bb_text: String) -> void:
	if not get_text_label():
		return
		
	get_text_label().append_text(bb_text + "\n")
	_trim_log()


func _trim_log() -> void:
	var total_lines := get_text_label().get_paragraph_count()
	var lines_to_remove := total_lines - get_max_lines()
	# __log_("total_lines", total_lines, "lines_to_remove", lines_to_remove)
	if lines_to_remove > 0:
		# always remove index 0 because the indices shift up after every removal
		for i in range(lines_to_remove):
			get_text_label().remove_paragraph(0)


## UTILITIES THAT CAN BE USED

func _apply_regex_filter(text_fragments: Array[String], dtc_section: DTS.DTSection, dtc_key: int) -> RegexFilter.Result:
	var filter_text := ""
	var dtc = GlobalUIInfo.get_dev_tools_config()
	if dtc:
		filter_text = dtc.sget_value(dtc_section, dtc_key)

	var regex_r := _regex_filter.apply_filter(pp.s(text_fragments), filter_text)
	return regex_r


func _append_invalid_regex_text_to_label():
	_append_text_to_label(INVALID_REGEX_TEXT)


func _format_time() -> String:
	var time_bb := BB.color_wrap(TimeUtils.get_time_string_from_system_mm_ss(), COL_TIME)
	return time_bb


func _format_frame(frame: Variant):
	return BB.color_wrap("[" + str(frame) + "]", COL_FRAME)


func _log_prefix(frame: Variant) -> String:
	return BB.b_wrap(_format_time() + " " + _format_frame(frame)).strip_edges()
