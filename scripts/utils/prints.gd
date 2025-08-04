class_name print_ extends RefCounted


static func _prefix(prefix: String, text: String, info_indents: int = 0):
	var tabs_prefix := __calculate_tab_prefix(info_indents)
	prefix = "[" + prefix + "]" + "  "
	print(tabs_prefix, prefix, text)


static func _debug_(text, info_indents: int = 0):
	var tabs_prefix := __calculate_tab_prefix(info_indents)
	print(tabs_prefix, "[DEBUG] ", text)

static func _ready(node: Node, info_indents: int = 0):
	print("||", node.name, " ready()")
	_info(node, "", 1)


static func _info(node: Node, prefix: String = "", info_indents: int = 0):
	"""
	Prints detailed information about the given node for debugging purposes.
	"""
	if prefix:
		print(prefix)

	var tabs_prefix := __calculate_tab_prefix(info_indents)

	print(tabs_prefix, "Node name: ", node.name)
	print(tabs_prefix, "Node type: ", node.get_class())
	print(tabs_prefix, "Node path: ", node.get_path())
	# print("Is inside tree:", node.is_inside_tree())
	# print("Parent:", node.get_parent())
	# print("Children count:", node.get_child_count())
	# var groups = node.get_groups()
	# print("Groups:", ", ".join(groups) if groups.size() > 0 else "(none)")


static func __calculate_tab_prefix(info_indents: int) -> String:
	var tabs_prefix = ""
	if info_indents:
		for i in range(info_indents):
			tabs_prefix += "    "
	return tabs_prefix