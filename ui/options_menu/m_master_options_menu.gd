class_name M_MasterOptionsMenu
extends Control

# This script enables keyboard navigation for a tabbed options menu.
# It allows the player to cycle through the tabs of a TabContainer using 
# the ui_page_up and ui_page_down input actions (PageUp/PageDown on a keyboard). 
# Ppressing next on the last tab goes to the first, and vice-versa.
# This logic is only active when the menu is visible.

func _unhandled_input(event : InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_page_down"):
		$TabContainer.current_tab = ($TabContainer.current_tab+1) % $TabContainer.get_tab_count()
	elif event.is_action_pressed("ui_page_up"):
		if $TabContainer.current_tab == 0:
			$TabContainer.current_tab = $TabContainer.get_tab_count()-1
		else:
			$TabContainer.current_tab = $TabContainer.current_tab-1
