class_name ReUtils
extends RefCounted


class RegexCompileInfo:
	var is_valid: bool = true
	var is_inverted: bool = false
	var pattern: String = ""


static func check_regex_compile(query: String) -> RegexCompileInfo:
	var info := RegexCompileInfo.new()
	
	info.is_inverted = query.begins_with("!")
	info.pattern = query.trim_prefix("!")
	
	# "!" alone is invalid
	if info.is_inverted and info.pattern.is_empty():
		info.is_valid = false
	elif not info.pattern.is_empty():
		var regex := RegEx.new()
		if regex.compile(info.pattern) != OK:
			info.is_valid = false

	return info