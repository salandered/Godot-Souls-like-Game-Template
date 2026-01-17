class_name TutorialUI
extends Node

## assign it to node somewhere close the FirstTutorial or similar


# Maps number keys (1-9) to tutorial panel nodes
var _tutorial_panels: Dictionary[int, Control] = {}


# Call this during _ready() to register a panel with its key
func register_panel(key_number: int, panel: Control) -> void:
	if key_number < 1 or key_number > 9:
		push_error("TutorialOverlay: key_number must be between 1 and 9")
		return
	
	if not panel:
		return
		
	_tutorial_panels[key_number] = panel
	panel.hide() # Start hidden


func unregister_panel(key_number: int) -> void:
	_tutorial_panels.erase(key_number)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_code = event.keycode

		var number: int = -1
		
		# Main keyboard number keys
		if key_code > KEY_0 and key_code <= KEY_9:
			number = key_code - KEY_0
		# Numpad keys
		elif key_code > KEY_KP_0 and key_code <= KEY_KP_9:
			number = key_code - KEY_KP_0
		
		if number > 0 and _tutorial_panels.has(number):
			_toggle_panel(number)
			get_viewport().set_input_as_handled()


func _toggle_panel(key_number: int) -> void:
	if _tutorial_panels.has(key_number):
		var panel: Control = _tutorial_panels[key_number]
		if panel:
			if not panel.visible:
				hide_all() # hide all others
				panel.show()
			else:
				panel.hide() # if it is already visible, hide it


func hide_all() -> void:
	for panel in _tutorial_panels.values():
		if panel:
			panel.hide()


func is_any_visible() -> bool:
	for panel in _tutorial_panels.values():
		if panel and panel.visible:
			return true
	return false
