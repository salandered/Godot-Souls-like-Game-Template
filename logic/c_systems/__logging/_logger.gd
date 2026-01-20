extends RefCounted
class_name log


const _FRAME_PRINT := true

static var _last_prefix_msg := ""


static func prefix(is_warning: bool, prefix_: String, text: String = "", info_indents: int = 0, ):
	if not OS.is_debug_build() and not is_warning:
		return
	var tabs_prefix := __calculate_tab_prefix(info_indents)
	
	prefix_ = prefix_.strip_edges()
	prefix_ = pp.in_sq(prefix_)
	
	var fr_ := ""
	if _FRAME_PRINT:
		var _metka := " "
		if u.ifr() % 15 == 0 and u.ifr() != 0:
			_metka = "-"
		if u.ifr() % 60 == 0 and u.ifr() != 0:
			_metka = "x"
		fr_ = "%6s" % [u.sfr() + "|" + _metka + " "]
	
	var result_msg := tabs_prefix + "  " + prefix_ + "  " + text
	
	if result_msg == _last_prefix_msg:
		print("%4s" % ["| "], result_msg)
		return

	_last_prefix_msg = result_msg
	print(fr_, result_msg)


static func prefix_s(is_warning: bool = false, ...parts: Array):
	if not OS.is_debug_build():
		return
	var _prefix := ""
	var _msg := ""
	if parts.is_empty():
		_prefix = ""
		_msg = "no text provided"
	elif len(parts) == 1:
		_prefix = str(parts[0])
		_msg = ""
	else:
		_prefix = str(parts[0])
		_msg = pp.list_(parts.slice(1))
	prefix(is_warning, _prefix, _msg)


static func __calculate_tab_prefix(info_indents: int) -> String:
	var cache: Dictionary[int, String] = {
		0: "",
		1: "    ",
		2: "        ",
		3: "            ",
		4: "                ",
		6: "                        ",
		8: "                                ",
		10: "                                        ",
		16: "                                                                ",
	}
	if cache.has(info_indents):
		return cache[info_indents]

	var tabs_prefix := ""
	if info_indents:
		for i in range(info_indents):
			tabs_prefix += "    "
	return tabs_prefix
