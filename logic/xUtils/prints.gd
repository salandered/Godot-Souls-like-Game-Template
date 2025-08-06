class_name print_ extends RefCounted


static func prefix(prefix_: String, text: String, info_indents: int = 0):
	var tabs_prefix := __calculate_tab_prefix(info_indents)
	prefix_ = "[" + prefix_ + "]" + "  "
	print(tabs_prefix, prefix_, text)


static func _debug_(text, info_indents: int = 0):
	var tabs_prefix := __calculate_tab_prefix(info_indents)
	print(tabs_prefix, "[DEBUG] ", text)

static func _ready(node: Node, info_indents: int = 0):
	print("||", node.name, " ready()")
	_info(node, "", 1)


static func _info(node: Node, prefix_: String = "", info_indents: int = 0):
	"""
	Prints detailed information about the given node for debugging purposes.
	"""
	if prefix_:
		print(prefix_)

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


static func collisions(node: Node, info_indents: int = 0):
	var layer = node.collision_layer
	var mask = node.collision_mask
		# Debug print the values
	print("Collision Layer: ", layer, " (binary: ", str(layer).pad_zeros(32), ")")
	print("Collision Mask: ", mask, " (binary: ", str(mask).pad_zeros(32), ")")

	# Alternative: print in binary format more clearly
	print("Collision Layer binary: ", String.num_uint64(layer, 2))
	print("Collision Mask binary: ", String.num_uint64(mask, 2))
	
	# Print the bit positions (layer numbers)
	print("Collision Layer: ", __get_bit_position(layer), " (value: ", layer, ")")
	print("Collision Mask: ", __get_bit_position(mask), " (value: ", mask, ")")

static func __get_bit_position(value: int) -> int:
	# Returns the position of the first set bit (0-indexed)
	if value == 0:
		return -1
	
	for i in range(32):
		if value & (1 << i):
			return i
	return -1
