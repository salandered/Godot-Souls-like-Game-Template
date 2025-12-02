@tool
extends RefCounted
class_name __log_script


static func error_(prefix: String, what: String, where: String, fallback: String, ...context: Array):
	var _msg = "Problem: %s. Where: '%s'. Fallback: %s" % [what, where, fallback]
	if not context.is_empty():
		_msg += " | Details: " + pp.list_(context)
	var _r := print_.parse_prefix(prefix)
	print_.prefix("❌" + _r.prefix, _msg, _r.index)


static func info_(prefix: String, ...parts: Array):
	var _r := print_.parse_prefix(prefix)
	print_.prefix(_r.prefix, pp.list_(parts), _r.index)


static func start_(name: String = "unnamed script"):
	info_("", "\n\n\n========================================")
	info_("", "===", name, "STARTED ===")
	info_("", "========================================\n")


static func end_(name: String = "unnamed script"):
	info_("", "\n========================================")
	info_("", "===", name, "COMPLETE ===")
	info_("", "========================================\n\n")
