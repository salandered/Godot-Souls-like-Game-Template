class_name _LowLevelPrinter
extends RefCounted


## Should be the only one who actually prints
## Not used by the client code, only public printer or frameworks


const NO_TEXT_PROVIDED := "no text provided"
const SAME_MESSAGE_AGAIN := "<same message again>"
const WARN_MSG_PREFIX := em.warn + " WARNING |"
const TAB_CRUCIAL := "\t" + em.crucial_x2
const SPLIT_HYPTHEN := "|- "
const SPLIT_X := "|x "
const SAME_MESSAGE_AGAIN_FORMATTED := pp.TAB_X2 + pp.SPLIT + " " + SAME_MESSAGE_AGAIN

const _FRAME_MARK_PRINT := true

static var _last_prefix_msg := ""
static var _last_warn_msg := ""


static func print_warn_message(incoming_msg_raw: String, warn_level: StringName = WL.PUSH_ERROR):
	if warn_level == WL.SILENT: return

	if incoming_msg_raw == _last_warn_msg:
		print_msg_formatted(false, "", SAME_MESSAGE_AGAIN_FORMATTED)
		return

	_last_warn_msg = incoming_msg_raw

	var incoming_msg := pp.s(WARN_MSG_PREFIX, incoming_msg_raw)

	match warn_level:
		WL.SILENT:
			pass
		WL.INFO:
			var info_msg := pp.s(em.note_alt, incoming_msg_raw) # incoming_msg_raw
			print_msg_formatted(false, pp.TAB, info_msg)
		## soft equals warn here
		WL.WARN:
			print_msg_formatted(true, pp.TAB, incoming_msg)
		WL.WARN_CRUCIAL:
			print_msg_formatted(true, TAB_CRUCIAL, incoming_msg)
		WL.ASSERT:
			print_msg_formatted(true, TAB_CRUCIAL, incoming_msg)
			push_error(incoming_msg) # important!
			assert(false, incoming_msg)
		WL.PUSH_ERROR:
			print_msg_formatted(true, TAB_CRUCIAL, incoming_msg)
			push_error(incoming_msg)
		WL.PUSH_WARN:
			print_msg_formatted(true, TAB_CRUCIAL, incoming_msg)
			push_warning(incoming_msg)
		_:
			print_msg_formatted(true, TAB_CRUCIAL,
					pp.s("Unknown warn level!", pp.in_q(warn_level), "Will be treated as PUSH_ERROR"))
			print_msg_formatted(true, TAB_CRUCIAL, incoming_msg)
			push_error(incoming_msg)


static func print_msg_formatted(is_warning: bool, prefix_: String, text: String = "", info_indents: int = 0):
	if eu.is_release() and not is_warning:
		return

	prefix_ = prefix_.strip_edges()
	prefix_ = pp.in_sq(prefix_)
	
	var prefix_text_msg := prefix_ + "  " + text
	
	if prefix_text_msg == _last_prefix_msg:
		print("   | ", SAME_MESSAGE_AGAIN)
		return
	_last_prefix_msg = prefix_text_msg


	var _mark := "|  "
	var ifr := FrameUtils.ifr()
	if _FRAME_MARK_PRINT and ifr != 0:
		if ifr % 60 == 0:
			_mark = SPLIT_X
		elif ifr % 15 == 0:
			_mark = SPLIT_HYPTHEN
	var fr_ := "%7s" % [str(ifr) + _mark]
	

	var tabs_prefix := StrUtils.calculate_tab_prefix(info_indents)
	var result_msg := tabs_prefix + prefix_text_msg

	print(fr_, result_msg)
	
	if eu.is_editor() or eu.is_release():
		return
	__emit_print_signals(is_warning, prefix_text_msg)


## friendly wrapper around print_msg_formatted
static func print_msg_raw(is_warning: bool, ...parts: Array):
	if eu.is_release():
		return
	var _prefix := ""
	var _msg := ""
	if parts.is_empty():
		_msg = NO_TEXT_PROVIDED
	elif len(parts) == 1:
		_prefix = str(parts[0])
	else:
		_prefix = str(parts[0])
		_msg = pp.list_(parts.slice(1))
	print_msg_formatted(is_warning, _prefix, _msg)


## used only for metric/analytical reasons 
static func __emit_print_signals(is_warning: bool, prefix_text_msg: String) -> void:
	if GlobalUIInfo.__ERROR_LOG and is_warning:
		SigUtils.safe_emit(GlobalSignal.__SIG_error_log_printed, {
			SPS.frame_field: FrameUtils.sfr(), # string
			SPS.message_field: prefix_text_msg
			})
	if GlobalUIInfo.__ALL_LOG:
		SigUtils.safe_emit(GlobalSignal.__SIG_all_log_printed, {
			SPS.frame_field: FrameUtils.sfr(),
			SPS.message_field: prefix_text_msg
			})
