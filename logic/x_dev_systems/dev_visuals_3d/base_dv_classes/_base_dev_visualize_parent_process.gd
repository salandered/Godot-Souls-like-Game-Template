@tool

@abstract
class_name BaseDevVisualizeParent
extends BaseDevVisualizeProcess3D


var _parent_node: Node3D


func __hard_dependencies() -> Array:
	return [
		_parent_node
	]


func _initialize_implementation_both_editor_and_game() -> void:
	super._initialize_implementation_both_editor_and_game()
	if get_parent() is Node3D:
		_parent_node = get_parent()
		__log_("_ready", "parent set", _parent_node)
