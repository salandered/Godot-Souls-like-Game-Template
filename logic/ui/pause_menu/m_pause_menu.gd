@tool
class_name M_PauseMenu
extends M_OverlaidMenu


@export var options_packed_scene: PackedScene
@export var ui_overlay_controls_packed_scene: PackedScene
@export_file("*.tscn") var main_menu_scene: String


var popup_open: Node


@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var menu_buttons: BoxContainer = %MenuButtons
@onready var show_ui_overlay_controls_button: Button = %ShowUIOverlayControls

var ui_overlay_controls_panel: UIDVMenu


func _ready() -> void:
	if u.is_editor():
		return
	_hide_exit_for_web()
	_hide_options_if_unset()
	_hide_main_menu_if_unset()
	_hide_global_ui_overlay_controls_if_unset()
	
	if ui_overlay_controls_packed_scene and h_box_container:
		var _ui_overlay_controls := ui_overlay_controls_packed_scene.instantiate()
		if _ui_overlay_controls and _ui_overlay_controls is UIDVMenu:
			ui_overlay_controls_panel = _ui_overlay_controls
			h_box_container.add_child(_ui_overlay_controls)

	if ui_overlay_controls_panel:
		ui_overlay_controls_panel.visible = GlobalUIInfo.ui_overlay_controls_visible
	
	TextureUtils.randomize_shake_button_panel_region(menu_buttons, 350)
	TextureUtils.randomize_button_normal_region(ui_overlay_controls_panel, 120, false)


func _handle_cancel_input() -> void:
	if popup_open:
		_close_popup()
	else:
		super._handle_cancel_input()


func _close_popup() -> void:
	if popup_open:
		popup_open.hide()
		popup_open = null


func _load_scene(scene_path: String) -> void:
	_scene_tree.paused = false
	M_SceneLoader.load_scene(scene_path)


## AUTO HIDE
# region

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		%ExitButton.hide()

func _hide_options_if_unset() -> void:
	if not options_packed_scene:
		%OptionsButton.hide()

func _hide_main_menu_if_unset() -> void:
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()

func _hide_global_ui_overlay_controls_if_unset() -> void:
	if not ui_overlay_controls_packed_scene or not h_box_container:
		show_ui_overlay_controls_button.hide()


# endregion


## OPTION MENU LOGIC
# region

func _open_options_menu() -> void:
	var options_scene := options_packed_scene.instantiate()
	if not options_scene or options_scene is not M_MasterOptionsMenu:
		return

	var casted_option_scene := options_scene as M_MasterOptionsMenu

	var cl := CanvasLayer.new()

	if not cl:
		return
		
	add_child(cl)
	cl.layer = 90
	cl.add_child(casted_option_scene)

	# casted_option_scene.set_transparency(1.0)
	
	if h_box_container:
		h_box_container.visible = false
	
	_disable_focus.call_deferred()
	await casted_option_scene.tree_exiting
	_enable_focus.call_deferred()
	
	if h_box_container:
		h_box_container.visible = true

	
func _disable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_NONE

func _enable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_ALL


# endregion


## ON BUTTON PRESSED
# region

func _on_restart_button_pressed() -> void:
	%ConfirmRestart.popup_centered()
	popup_open = %ConfirmRestart


func _on_options_button_pressed() -> void:
	_open_options_menu()


func _on_main_menu_button_pressed() -> void:
	%ConfirmMainMenu.popup_centered()
	popup_open = %ConfirmMainMenu


func _on_exit_button_pressed() -> void:
	%ConfirmExit.popup_centered()
	popup_open = %ConfirmExit


func _on_confirm_restart_confirmed() -> void:
	M_SceneLoader.reload_current_scene()
	close()


func _on_confirm_main_menu_confirmed() -> void:
	GlobalUIInfo.ui_overlay_controls_visible = false
	if ui_overlay_controls_panel:
		ui_overlay_controls_panel.visible = GlobalUIInfo.ui_overlay_controls_visible
	
	_load_scene(main_menu_scene)


func _on_confirm_exit_confirmed() -> void:
	get_tree().quit()


func _on_show_ui_overlay_controls_pressed() -> void:
	GlobalUIInfo.ui_overlay_controls_visible = not GlobalUIInfo.ui_overlay_controls_visible
	if ui_overlay_controls_panel:
		ui_overlay_controls_panel.visible = GlobalUIInfo.ui_overlay_controls_visible

# endregion
