class_name M_MainMenu
extends ControlSystem


signal SIG_sub_menu_opened
signal SIG_sub_menu_closed
signal SIG_game_exited


@export_file("*.tscn") var game_scene_path: String
@export var options_packed_scene: PackedScene
@export var credits_packed_scene: PackedScene
@export var gallery_packed_scene: PackedScene

@export_category("Level Selection")
@export_file("*.tscn") var level_1_scene_path: String
@export_file("*.tscn") var level_2_scene_path: String

@export_category("Extra Settings")
@export var initial_focus_target: Control

@export_category("DEV Settings")
@export var __turn_on_tut_on_start: bool = true
@export var __dev_bypass_menu_and_start_game: bool = false
@export var __dev_bypass_menu_and_start_arena: bool = false

@onready var menu_container: MarginContainer = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button = %ExitButton
@onready var options_container = %OptionsContainer
@onready var credits_container = %CreditsContainer
@onready var gallery_container: MarginContainer = %GalleryContainer
@onready var back_button_container = %BackButtonContainer
@onready var fade_overlay: ColorRect = %FadeOverlay
@onready var hide_label_container: MarginContainer = %HideLabelContainer
@onready var menu_3d_scene: Menu3DLevel = %Menu3DScene

var options_scene
var credits_scene
var sub_menu: Control

const MAX_MAIN_MENU_TRACK_CUTOFF := 950
const MAIN_MENU_TRACK_CUTOFF_HZ := 200
const CUTOFF_HZ_DURATION = 43.0


var _music_low_pass_filter: AudioEffectLowPassFilter

# Base class for a main menu UI.
# - Launches the game using the M_SceneLoader autoload.
# - Emits signals for game start / exit to allow for custom loading or transition logic.
# - Manages navigation between the main menu and sub-menus (Options, Credits).
# - Handles exiting the application.
# - Interacts with the M_GameState autoload to manage save data.


func __hard_dependencies() -> Array:
	return [
		menu_container,
		menu_buttons_box_container,
		options_button
		]


func __soft_dependencies() -> Array:
	return [
		exit_button,
		credits_button,
		menu_3d_scene
		]


## INITIALIZATION
# region

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	back_button_container.visible = false

	_add_or_hide_options()
	_add_or_hide_credits()
	
	_grab_initial_focus()
	
	_play_visuals_fade_in()
	_music_cutoff_fade_in()
	
	ThemeUtils.randomize_shake_button_panel_region(menu_buttons_box_container, 450)
	
	menu_3d_scene.initialize()
	
	if __dev_bypass_menu_and_start_game:
		await FrameUtils.wait_process_frames(self , 2)
		_on_level_2_button_pressed()
		return
	if __dev_bypass_menu_and_start_arena:
		await FrameUtils.wait_process_frames(self , 2)
		_on_level_1_button_pressed()
		return

	__perform_validation()
		

func _play_visuals_fade_in() -> void:
	if not fade_overlay:
		return
	
	fade_overlay.show()
	fade_overlay.modulate.a = 1.0
	
	var tween := create_tween()
	tween.tween_property(fade_overlay, PropC.MODULATE_A, 0.0, 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(fade_overlay.hide)


func _music_cutoff_fade_in() -> void:
	_music_low_pass_filter = AudioServerUtil.get_lowpass_filter(BusID.MENU_MUSIC)
	if _music_low_pass_filter:
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(
			_music_low_pass_filter,
			PropC.CUTOFF_HZ,
			MAX_MAIN_MENU_TRACK_CUTOFF,
			CUTOFF_HZ_DURATION) \
				.from(MAIN_MENU_TRACK_CUTOFF_HZ)
		__log_(_music_low_pass_filter, tween)


func _grab_initial_focus() -> void:
	if not initial_focus_target:
		__log_("_grab_initial_focus", "no initial_focus_target")
		return
	if initial_focus_target and initial_focus_target.is_visible_in_tree():
		initial_focus_target.grab_focus()
		return


func _add_or_hide_options() -> void:
	if not options_packed_scene:
		options_button.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		options_container.show()
		options_container.call_deferred(PropC.ADD_CHILD, options_scene)


func _add_or_hide_credits() -> void:
	if not credits_packed_scene:
		credits_button.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		credits_container.show()
		credits_container.call_deferred(PropC.ADD_CHILD, credits_scene)

# endregion


func exit_game() -> void:
	SigUtils.safe_emit_no_payload(SIG_game_exited)
	get_tree().quit()


## LOAD LEVEL
# region

func _load_specific_level(path: String) -> void:
	_reset_audio_state()
	if path.is_empty():
		__log_warn("path is empty", "_load_specific_level", "return", path)
		return

	# Ensure we aren't carrying over old state when jumping to a specific level
	if M_GameState.has_game_state():
		M_GameState.reset()

	if __turn_on_tut_on_start:
		GlobalUIInfo.toggle_tutorial(true)
	
	M_SceneLoader.load_scene(path)


func _reset_audio_state() -> void:
	if _music_low_pass_filter:
		_music_low_pass_filter.cutoff_hz = MAIN_MENU_TRACK_CUTOFF_HZ

# endregion 


## SHOW/HIDE menu
# region

func _toggle_menu_visible(toggle: bool) -> void:
	menu_container.visible = toggle
	back_button_container.visible = not toggle


func _toggle_scenery_view() -> void:
	menu_container.visible = not menu_container.visible


func _open_sub_menu(menu: Control) -> void:
	sub_menu = menu
	sub_menu.show()

	_toggle_menu_visible(false)
	
	SIG_sub_menu_opened.emit()
	
	if hide_label_container:
		hide_label_container.hide()


func _close_sub_menu() -> void:
	if not sub_menu:
		return

	var closing_menu := sub_menu

	sub_menu.hide()
	sub_menu = null
	_toggle_menu_visible(true)
	SIG_sub_menu_closed.emit()

	if hide_label_container:
		hide_label_container.show()

	## TODO: gallery created some branching here
	if closing_menu.get_parent() == gallery_container:
		closing_menu.queue_free()
		__log_("_close_sub_menu", "Gallery freed")

# endregion


## INPUT
# region

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()

	_scenery_view_input(event)


func _scenery_view_input(event: InputEvent) -> void:
	match InputUtils.get_keycode(event):
		KEY_0, KEY_KP_0:
			if hide_label_container.visible == false:
				return
			_toggle_scenery_view()
			InputUtils.mark_input_handled(self )

# endregion


## ON BUTTON PRESSED
# region

func _on_level_1_button_pressed() -> void:
	_load_specific_level(level_1_scene_path)


func _on_level_2_button_pressed() -> void:
	_load_specific_level(level_2_scene_path)


func _on_options_button_pressed() -> void:
	_open_sub_menu(options_scene)


func _on_credits_button_pressed() -> void:
	_open_sub_menu(credits_scene)


func _on_gallery_button_pressed() -> void:
	if not gallery_packed_scene:
		__log_warn("Gallery scene not assigned in Main Menu")
		return

	var gallery_instance = gallery_packed_scene.instantiate()
	if not gallery_instance or gallery_instance is not BaseImageGallery:
		__log_warn("Some problem with gallery")
		return
	
	gallery_container.add_child(gallery_instance)
	
	_open_sub_menu(gallery_instance)
	back_button_container.visible = false


func _on_exit_button_pressed() -> void:
	exit_game()


func _on_back_button_pressed() -> void:
	_close_sub_menu()

# endregion


## __LOGS

func __LOG_B() -> bool:
	return LogToggler.UI.MAIN_MENU
