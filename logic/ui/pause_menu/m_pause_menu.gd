@tool
class_name M_PauseMenu
extends M_OverlaidMenu

@export var options_packed_scene: PackedScene
@export_file("*.tscn") var main_menu_scene: String

var popup_open: Node


@onready var show_ui_overlay_controls: Button = %ShowUIOverlayControls

@onready var dynamic_state_info_option: OptionButton = %DynamicStateInfoOption
@onready var menu_buttons: BoxContainer = %MenuButtons

@onready var ui_overlay_controls: PanelContainer = %UIOverlayControls
@onready var camera_nodes_toggle: CheckButton = %CameraNodesToggler
@onready var tutorial_toggler: CheckButton = %TutorialToggler
@onready var profiler_toggler: CheckButton = %ProfilerToggler


enum DynamicStateInfoOption {
	OFF, # 0
	PLAYER, # 1
	HSM_ENEMY, # 2
	SIMPLE_ENEMY # 3
	}


func _ready() -> void:
	_hide_exit_for_web()
	_hide_options_if_unset()
	_hide_main_menu_if_unset()
	# tutorial_toggler.
	if ui_overlay_controls:
		ui_overlay_controls.visible = GlobalUIInfo.ui_overlay_controls_visible
	if dynamic_state_info_option:
		if GlobalUIInfo.is_dynamic_state_info_visible():
			dynamic_state_info_option.select(DynamicStateInfoOption.PLAYER)
		elif GlobalUIInfo.is_phe_dynamic_state_info_visible():
			dynamic_state_info_option.select(DynamicStateInfoOption.HSM_ENEMY)
		elif GlobalUIInfo.is_se_dynamic_state_info_visible():
			dynamic_state_info_option.select(DynamicStateInfoOption.SIMPLE_ENEMY)
		else:
			dynamic_state_info_option.select(DynamicStateInfoOption.OFF)

	if tutorial_toggler:
		tutorial_toggler.set_pressed_no_signal(GlobalUIInfo.is_tut_visible())
	if profiler_toggler:
		profiler_toggler.set_pressed_no_signal(GlobalUIInfo.is_profiler_visible())
	if camera_nodes_toggle:
		camera_nodes_toggle.set_pressed_no_signal(GlobalUIInfo.is_in_game_subvp_active())
	
	TextureUtils.randomize_shake_button_panel_region(menu_buttons, 350)
	TextureUtils.randomize_button_normal_region(ui_overlay_controls, 120, false)


func close_popup() -> void:
	if popup_open != null:
		popup_open.hide()
		popup_open = null


func _disable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_NONE

func _enable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_ALL

func _load_scene(scene_path: String) -> void:
	_scene_tree.paused = false
	SigUtils.safe_emit_raw(GlobalSignal.SIG_toggle_show_tut, {GlobalSignal.payload_toggle_field: false})
	M_SceneLoader.load_scene(scene_path)


func open_options_menu() -> void:
	var options_scene := options_packed_scene.instantiate()
	add_child(options_scene)
	
	# Hide existing pause menu elements, excluding the new options scene
	_toggle_content_visibility(false, options_scene)
	
	_disable_focus.call_deferred()
	await options_scene.tree_exiting
	_enable_focus.call_deferred()
	
	# Restore visibility of pause menu elements
	_toggle_content_visibility(true)

# New helper function to hide/show siblings without affecting the active options menu
func _toggle_content_visibility(is_visible_: bool, exclude: Node = null) -> void:
	for child in get_children():
		if child is Control and child != exclude:
			child.visible = is_visible_


func _handle_cancel_input() -> void:
	if popup_open != null:
		close_popup()
	else:
		super._handle_cancel_input()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		%ExitButton.hide()

func _hide_options_if_unset() -> void:
	if options_packed_scene == null:
		%OptionsButton.hide()

func _hide_main_menu_if_unset() -> void:
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()


func _on_restart_button_pressed() -> void:
	%ConfirmRestart.popup_centered()
	popup_open = %ConfirmRestart

#
func _on_options_button_pressed() -> void:
	open_options_menu()

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
	## turn off some ui overlay controls
	_emit_SIG_toggle_dynamic_state_info(false, false, false)
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_show_tut, false)
	
	##
	_load_scene(main_menu_scene)

func _on_confirm_exit_confirmed() -> void:
	get_tree().quit()


##


func _on_show_ui_overlay_controls_pressed() -> void:
	GlobalUIInfo.ui_overlay_controls_visible = not GlobalUIInfo.ui_overlay_controls_visible
	ui_overlay_controls.visible = GlobalUIInfo.ui_overlay_controls_visible


func _on_profiler_toggler_toggled(toggled_on: bool) -> void:
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_show_profiler, toggled_on)


func _on_tutorial_toggler_toggled(toggled_on: bool) -> void:
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_show_tut, toggled_on)

	if toggled_on and dynamic_state_info_option.selected == DynamicStateInfoOption.HSM_ENEMY:
		dynamic_state_info_option.select(DynamicStateInfoOption.OFF)
		_emit_SIG_toggle_dynamic_state_info(false, false, false)


func _on_option_button_item_selected(index: int) -> void:
	match index:
		DynamicStateInfoOption.OFF:
			_emit_SIG_toggle_dynamic_state_info(false, false, false)
		DynamicStateInfoOption.PLAYER:
			_emit_SIG_toggle_dynamic_state_info(true, false, false)
		DynamicStateInfoOption.HSM_ENEMY:
			_emit_SIG_toggle_dynamic_state_info(false, true, false)
			if tutorial_toggler:
				tutorial_toggler.button_pressed = false ## will emit signal
		DynamicStateInfoOption.SIMPLE_ENEMY:
			_emit_SIG_toggle_dynamic_state_info(false, false, true)
		_:
			__log_warn_soft("unknown index", "", "all off", index)
			_emit_SIG_toggle_dynamic_state_info(false, false, false)

	pass # Replace with function body.


func _emit_SIG_toggle_dynamic_state_info(player: bool, enemy: bool, se: bool):
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_dynamic_state_info, player)
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_phe_dynamic_state_info, enemy)
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_se_dynamic_state_info, se)


func _on_camera_nodes_toggler_toggled(toggled_on: bool) -> void:
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_toggle_camera_visuals, toggled_on)
