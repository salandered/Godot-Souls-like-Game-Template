@tool

@abstract
class_name BaseDevVisualiseParent
extends BaseDevVisualise


var _parent_node: Node3D


func __hard_dependencies() -> Array:
	return [
		_parent_node
	]


func initialise_implementation_both_editor_and_game() -> void:
	if get_parent() is Node3D:
		_parent_node = get_parent()
		# if not Engine.is_editor_hint():
		__log_("_ready", "parent set", _parent_node)
