extends RefCounted
class_name print_err


static func msg_formatted(msg: String, warn_level: StringName = WL.PUSH_ERROR):
	_LowLevelPrinter.print_warn_message(msg, warn_level)
