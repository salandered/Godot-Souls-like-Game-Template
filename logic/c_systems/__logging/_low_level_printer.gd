class_name _low_level_printer
extends RefCounted


## should be the only one who actually prints, and not used by client code


const _FRAME_PRINT := true

static var _last_prefix_msg := ""

static var _last_warn_msg := ""


static func _warn(warn_msg_: String, warn_level: String = WL.PUSH_ERROR):
	if warn_level == WL.SILENT: return

	var warn_msg := pp.s(em.warn, "WARNING |", warn_msg_)


	if warn_msg == _last_warn_msg:
		prefix_s(false, "\t\t |", "<same message again>")
		return
	_last_warn_msg = warn_msg

	match warn_level:
		WL.SILENT:
			pass
		WL.INFO:
			var info_msg := pp.s(em.note_alt, warn_msg)
			prefix_s(false, "\t", warn_msg)
		## soft equals warn here
		WL.WARN:
			prefix_s(true, "\t", warn_msg)
		WL.WARN_CRUCIAL:
			prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
		WL.ASSERT:
			prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_error(pp.s(em.crucial_x2, warn_msg)) # important!
			assert(false, pp.s(em.crucial_x2, warn_msg))
		WL.PUSH_ERROR:
			prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_error(pp.s(em.crucial_x2, warn_msg))
		WL.PUSH_WARN:
			prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_warning(warn_msg)
		_:
			prefix_s(true, "\t", em.crucial_x2, "Unknown warn level!", pp.in_q(warn_level), "Will be treated as PUSH_ERROR")
			prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_error(pp.s(em.crucial_x2, warn_msg))


static func prefix(is_warning: bool, prefix_: String, text: String = "", info_indents: int = 0, ):
	if not OS.is_debug_build() and not is_warning:
		return
	var tabs_prefix := StrUtils.calculate_tab_prefix(info_indents)
	
	prefix_ = prefix_.strip_edges()
	prefix_ = pp.in_sq(prefix_)
	
	var fr_ := ""
	if _FRAME_PRINT:
		var _mark := " "
		if u.ifr() % 15 == 0 and u.ifr() != 0:
			_mark = "-"
		if u.ifr() % 60 == 0 and u.ifr() != 0:
			_mark = "x"
		fr_ = "%6s" % [u.sfr() + "|" + _mark + " "]
	

	var prefix_text_msg := prefix_ + "  " + text
	
	if prefix_text_msg == _last_prefix_msg:
		print("%4s" % ["| "], prefix_text_msg)
		return
	_last_prefix_msg = prefix_text_msg
	
	var result_msg := tabs_prefix + prefix_text_msg


	print(fr_, result_msg)
	
	if u.is_editor():
		return
	if GlobalUIInfo.__ERROR_LOG and is_warning:
		SigUtils.safe_emit_raw(GlobalSignal.__SIG_error_log_printed, {
			SPS.frame_field: u.sfr(), # string
			SPS.message_field: prefix_text_msg
			})
	if GlobalUIInfo.__ALL_LOG:
		SigUtils.safe_emit_raw(GlobalSignal.__SIG_all_log_printed, {
			SPS.frame_field: u.sfr(),
			SPS.message_field: prefix_text_msg
			})


static func prefix_s(is_warning: bool = false, ...parts: Array):
	if u.is_release():
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
