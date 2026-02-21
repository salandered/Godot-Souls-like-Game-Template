class_name M_MasterOptionsMenu
extends Control


@export var transparent_panel: bool = true

@onready var panel_container: PanelContainer = %PanelContainer


# enables keyboard navigation for a tabbed options menu.
# allows the player to cycle through the tabs of a TabContainer using 
# the ui_page_up and ui_page_down input actions (PageUp/PageDown on a keyboard). 
# Pressing next on the last tab goes to the first, and vice-versa.
# This logic is only active when the menu is visible.


func _ready() -> void:
	if not transparent_panel:
		set_transparency(1.0)


func set_transparency(alpha: float):
	ControlUtils.override_panel_alpha(panel_container, alpha)


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_page_down"):
		%TabContainer.current_tab = (%TabContainer.current_tab + 1) % %TabContainer.get_tab_count()
	elif event.is_action_pressed("ui_page_up"):
		if %TabContainer.current_tab == 0:
			%TabContainer.current_tab = %TabContainer.get_tab_count() - 1
		else:
			%TabContainer.current_tab = %TabContainer.current_tab - 1
