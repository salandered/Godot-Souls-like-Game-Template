class_name Print extends RefCounted


static func print_ready(node: Node, info_indents: int = 0):
	print("||", node.name, " ready()")
	print_info(node, "", 1)


static func print_info(node: Node, prefix: String = "", info_indents: int = 0):
	"""
	Prints detailed information about the given node for debugging purposes.
	"""
	if prefix:
		print(prefix)

	var tabs_prefix = ""
	if info_indents:
		for i in range(info_indents):
			tabs_prefix += "    "
		tabs_prefix += "> "

	print(tabs_prefix, "Node name: ", node.name)
	print(tabs_prefix, "Node type: ", node.get_class())
	print(tabs_prefix, "Node path: ", node.get_path())
	# print("Is inside tree:", node.is_inside_tree())
	# print("Parent:", node.get_parent())
	# print("Children count:", node.get_child_count())
	# var groups = node.get_groups()
	# print("Groups:", ", ".join(groups) if groups.size() > 0 else "(none)")