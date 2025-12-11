extends RefCounted
class_name __log_ui


static func warn_(what: String, where: String = "", fallback: String = "", ...context: Array):
	where = pp.s("UI", where)
	error_.warn(what, where, fallback, WL.PUSH_WARN, pp.list_(context))


static func info_(prefix: String, ...parts: Array):
	prefix = pp.s("UI", prefix)
	var _r := print_.parse_prefix(prefix)
	print_.prefix(_r.prefix, pp.list_(parts), _r.index)
