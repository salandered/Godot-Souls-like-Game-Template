@tool
class_name M_OverlaidMenuContainer
extends M_OverlaidMenu

##"The Utility" This is a helper class that inherits from m_overlaid_menu.gd.
## - takes any arbitrary scene (like a generic Options Menu) 
## - and wraps it inside the "Overlaid Menu" logic.
##
## So if you have a simple Options.tscn that is just buttons, you can stick it inside this container. 
## Container (via M_OverlaidMenu) will handle pausing the game and showing the mouse.


@export var menu_scene : PackedScene :
	set(value):
		var _value_changed = menu_scene != value
		menu_scene = value
		if _value_changed:
			for child in %MenuContainer.get_children():
				child.queue_free()
			if menu_scene:
				var _instance = menu_scene.instantiate()
				%MenuContainer.add_child(_instance)
