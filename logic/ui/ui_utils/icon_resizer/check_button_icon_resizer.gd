@tool
class_name CheckButtonIconResizer
extends NodeLogger


@export_range(0.1, 3.0, 0.1) var base_scale: float = 1.0:
	set(value):
		base_scale = value
		if is_node_ready():
			_update_icons()



var _parent: CheckButton


func _ready() -> void:
	_update_icons()


func _update_icons() -> void:
	var parent_ := get_parent()
	if parent_ is CheckButton:
		_parent = parent_

	if _parent:
		_process_icon(_parent, "checked")
		_process_icon(_parent, "unchecked")


func _process_icon(parent: CheckButton, icon_name: String) -> void:
	if not parent: return
	if not parent.has_theme_icon_override(icon_name):
		__log_("not parent.has_theme_icon_override(icon_name), return", parent, icon_name)
		return

	var icon: Resource = parent.get_theme_icon(icon_name)
	
	if not icon or not "base_scale" in icon:
		__log_("not icon or not 'base_scale' in icon, return", icon_name, icon)
		return

	# duplicate if it's a saved resource (has a path) to avoid modifying shared files
	if not icon.resource_path.is_empty():
		icon = icon.duplicate()
		parent.add_theme_icon_override(icon_name, icon)
	else:
		__log_("icon.resource_path.is_empty(), no duplicating", icon_name, icon)

	icon.base_scale = base_scale
