extends RefCounted
class_name __log_ui


static func warn_(crucial: bool, what: String, where: String, fallback: String, ...context: Array):
	where = pp.s("UI", where)
	print_.warn(crucial, what, where, fallback, pp.list_(context))


static func info_(prefix: String, ...parts: Array):
	prefix = pp.s("UI", prefix)
	var _r := print_.parse_prefix(prefix)
	print_.prefix(_r.prefix, pp.list_(parts), _r.index)
