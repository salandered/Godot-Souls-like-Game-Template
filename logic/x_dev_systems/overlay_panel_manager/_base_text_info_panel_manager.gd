@tool

@abstract
class_name BaseTextInfoPanelManager
extends BasePanelManager


var _regex_filter := RegexFilter.new()


func __hard_validation() -> bool:
	var _r = super.__hard_validation()
	if not get_text_label():
		return false
	return _r


func initialise_implementation():
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

func _apply_regex_filter(text_fragments: Array[String], dvc_section: DVS.DVSection, dvc_key: int) -> RegexFilter.Result:
	var filter_text := ""
	var dvc = GlobalUIInfo.get_dev_visuals_config()
	if dvc:
		filter_text = dvc.sget_value(dvc_section, dvc_key)

	var regex_r := _regex_filter.apply_filter(pp.s(text_fragments), filter_text)
	return regex_r


var col_meta_err := "#ff868bff"
var invalid_regex_text := BB.color_wrap(BB.i_wrap("invalid regex"), col_meta_err)
func _append_invalid_regex_text_to_label():
	_append_text_to_label(invalid_regex_text)


var col_time := "#888888"
func _format_time() -> String:
	var time_bb := BB.color_wrap(u.get_time_string_from_system_mm_ss(), col_time)
	return time_bb


var col_frame := "#5bac7ae3"
func _format_frame(frame: Variant):
	return BB.color_wrap("[" + str(frame) + "]", col_frame)


func _log_prefix(frame: Variant) -> String:
	return BB.b_wrap(_format_time() + " " + _format_frame(frame)).strip_edges()
