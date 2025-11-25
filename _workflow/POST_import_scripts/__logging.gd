@tool
extends RefCounted
class_name __log_pi


static func error_(prefix: String, what: String, where: String, fallback: String, ...context: Array):
	var _msg = "Problem: %s. Where: '%s'. Fallback: %s" % [what, where, fallback]
	if not context.is_empty():
		_msg += " Details: " + pp.list_(context)
	var _r = __parse_prefix(prefix)
	print_.prefix("❌" + _r["result_str"], _msg, _r["index"])


static func info_(prefix: String, ...parts: Array):
	var _r = __parse_prefix(prefix)
	print_.prefix(_r["result_str"], pp.list_(parts), _r["index"])


static func start_():
	info_("", "\n\n\n========================================")
	info_("", "=== POST-IMPORT SCRIPT STARTED ===")
	info_("", "========================================\n")


static func end_():
	info_("", "\n========================================")
	info_("", "=== POST-IMPORT SCRIPT COMPLETE ===")
	info_("", "========================================\n\n")


static func __parse_prefix(prefix: String) -> Dictionary:
	var parts = prefix.split(" ", false)
	var result_str = parts[0] if parts.size() > 0 else ""
	var index = int(parts[1]) if parts.size() > 1 and parts[1].is_valid_int() else 0

	return {
		"result_str": result_str,
		"index": index
	}
