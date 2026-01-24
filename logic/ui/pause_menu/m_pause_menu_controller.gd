class_name M_PauseMenuController
extends NodeLogger

## Node for opening a pause menu when detecting a 'ui_cancel' event.
## Sits in your gameplay scene (not the UI) and waits for the player to press "ui_cancel" (Escape).
## When pressed, it instantiates (spawns) the m_pause_menu into the scene.


@export var pause_menu_packed: PackedScene
## Tells the controller which screen (Viewport) it should look at to find out which button was focused when the pause button was pressed.
## If assigned: forcing the menu to only care about focus within a specific sub-window (like Player 2's half of the screen).
## If empty: The script handles this automatically - defaults to get_viewport() (the main game screen).
## For a standard single-player game or demo, leave empty.
@export var focused_viewport: Viewport


func _ready() -> void:
	if not pause_menu_packed:
		__log_warn("no pause_menu_packed", "M_PauseMenuController", "")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not pause_menu_packed:
			__log_warn("no pause_menu_packed", "M_PauseMenuController", "")
			return
			
		if not focused_viewport:
			focused_viewport = get_viewport()
		var _initial_focus_control = focused_viewport.gui_get_focus_owner()

		var current_menu = pause_menu_packed.instantiate()
		get_tree().current_scene.call_deferred("add_child", current_menu)
		await current_menu.tree_exited
		if is_inside_tree() and _initial_focus_control:
			_initial_focus_control.grab_focus()


## __LOGS
# region

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion
