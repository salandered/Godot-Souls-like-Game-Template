extends RefCounted
class_name print_


## MAIN INFO LOGGING API (main functionality)

static func msg_raw(...parts: Array):
	_LowLevelPrinter.print_msg_raw(false, pp.list_(parts))


static func msg_formatted(prefix_: String, text: String = "", info_indents: int = 0):
	_LowLevelPrinter.print_msg_formatted(false, prefix_, text, info_indents)


static func dev(add_prefix_: String, ...parts: Array):
	msg_formatted(pp.s("dev |", add_prefix_), pp.list_(parts), 1)


static func note(bright: bool, ...parts: Array):
	var prefix := em.mark_x2 if bright else ""
	msg_formatted(pp.s(prefix, "📍NOTE (not warn)"), pp.list_(parts), 1)


static func console(...parts: Array):
	msg_formatted(pp.s(">>", em.console), pp.list_(parts), 7)


## ADVANCED PREFIX DECODING
## NOTE: used as an experiment in editor scripts only

class ParsedPrefix:
	var prefix: String
	var index: int

	func _init(prefix_: String, index_: int) -> void:
		prefix = prefix_
		index = index_

## "Tree" -> ("Tree", 0)
## "LOD 1" -> ("LOD", 1)
## "Wall Brick 05" -> ("Wall Brick", 5)  # <-- check
## "Level 2 Boss" -> ("Level 2 Boss", 0)
## "" -> ("", 0)
## "2" -> ("2", 0)
static func parse_prefix(encoded_prefix_: String) -> ParsedPrefix:
	var parts := encoded_prefix_.split(" ", false)

	if parts.size() == 0:
		return ParsedPrefix.new("", 0)

	if parts.size() == 1:
		return ParsedPrefix.new(parts[0], 0)


	var prefix_info = parts[0]
	var index := 0
	if parts[-1].is_valid_int():
		var prefix_parts = parts.slice(0, -1) # all except last
		prefix_info = " ".join(prefix_parts)
		index = int(parts[-1])
	else:
		prefix_info = " ".join(parts) # join all parts
		index = 0

	return ParsedPrefix.new(prefix_info, index)
