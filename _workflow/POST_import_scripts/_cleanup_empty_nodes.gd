@tool
extends RefCounted
class_name PICleanupEmptyNodes


## recursive
static func cleanup_empty_nodes(node: Node) -> void:
	var children_to_check := node.get_children().duplicate()
	
	for child in children_to_check:
		cleanup_empty_nodes(child)
	
	if node.get_class() == "Node3D" and node.get_child_count() == 0:
		if node.get_parent():
			__log_script.info_("CLEANUP", "  > Cleaning up empty Node3D:", node.name)
			node.get_parent().remove_child(node)
			node.free()
