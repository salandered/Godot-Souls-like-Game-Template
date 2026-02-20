@tool

@abstract
class_name BaseDevVisualiseParent
extends BaseDevVisualiseProcess3D


var _parent_node: Node3D


func __hard_dependencies() -> Array:
	return [
		_parent_node
	]


func _initialise_implementation_both_editor_and_game() -> void:
	super._initialise_implementation_both_editor_and_game()
	if get_parent() is Node3D:
		_parent_node = get_parent()
		# if not u.is_editor():
		__log_("_ready", "parent set", _parent_node)
