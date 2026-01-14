class_name M_MainMenu
extends ControlLogger

signal sub_menu_opened
signal sub_menu_closed
signal SIG_game_started # todo: do i need this?
signal game_exited

## Defines the path to the game scene.
@export_file("*.tscn") var game_scene_path: String
@export var options_packed_scene: PackedScene
@export var credits_packed_scene: PackedScene


@export_group("Level Selection") # added
@export_file("*.tscn") var level_1_scene_path: String
@export_file("*.tscn") var level_2_scene_path: String


@export_group("Extra Settings")
@export var signal_game_start: bool = false
@export var signal_game_exit: bool = false
@export var __dev_bypass_menu_and_start_game: bool = false # added
@export var initial_focus_target: Control # added

var options_scene
var credits_scene
var sub_menu

@onready var menu_container = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var new_game_button = %NewGameButton
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button = %ExitButton
@onready var options_container = %OptionsContainer
@onready var credits_container = %CreditsContainer
@onready var flow_control_container = %FlowControlContainer
@onready var back_button: Button = %BackButton
@onready var continue_game_button = %ContinueGameButton
@onready var fade_overlay: ColorRect = %FadeOverlay


@export var confirm_new_game: bool = true

@onready var menu_3d_scene: Menu3DLevel = %Menu3DScene


var MAX_MAIN_MENU_TRACK_CUTOFF := 950
var START_MAIN_MENU_TRACK_CUTOFF := 200


# A versatile base class for a main menu UI.
# - Handles 'Continue Game' and 'New Game' button presses.
#     Displays a confirmation pop-up before starting a new game if there's saved data.
# - Launches the game using the M_SceneLoader autoload.
# - Emits signals for game start / exit to allow for custom loading or transition logic.
# - Manages navigation between the main menu and sub-menus (Options, Credits).
# - Handles exiting the application.
# - Interacts with the M_GameState autoload to manage save data.


func _ready() -> void:
	# Check if the bypass flag is enabled
	if __dev_bypass_menu_and_start_game:
		# If a saved game exists, continue it. Otherwise, start a new one.
		# load_game_scene()
		_on_level_2_button_pressed()
		return # Stop here to prevent loading the menu UI

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Show the mouse cursor
	flow_control_container.show()
	_add_or_hide_options()
	_add_or_hide_credits()
	
	if game_scene_path.is_empty():
		new_game_button.disabled = true
	continue_game_button.disabled = not M_GameState.has_game_state()
	_grab_initial_focus()
	
	_play_fade_in()
	
	back_button.visible = false
	
	menu_3d_scene.initialise()
	
	_cutoff_fade_in()


func _play_fade_in() -> void:
	if not fade_overlay:
		return
	
	fade_overlay.show()
	fade_overlay.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, Constants.Prop.CONTROL_MODULATE_A, 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(fade_overlay.hide)

var effect: AudioEffectLowPassFilter
func _cutoff_fade_in() -> void:
	effect = AudioServerUtil.get_lowpass_filter(BusID.MENU_MUSIC)
	if effect:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(effect, "cutoff_hz", MAX_MAIN_MENU_TRACK_CUTOFF, 43.0).from(200.0)
		__log_(effect, tween)


# func _process(delta: float) -> void:
	# prints(effect.cutoff_hz)

func _grab_initial_focus() -> void:
	if not initial_focus_target: # I dont think I need initial focus
		__log_("Main menu", "no initial_focus_target")
		return
	if initial_focus_target and initial_focus_target.is_visible_in_tree():
		initial_focus_target.grab_focus()
		return

	if not continue_game_button.disabled and continue_game_button.is_visible_in_tree():
		continue_game_button.grab_focus()
	elif not new_game_button.disabled and new_game_button.is_visible_in_tree():
		new_game_button.grab_focus()


func _load_specific_level(path: String) -> void:
	_reset_audio_state()
	if path.is_empty():
		__log_warn("path is empty", "_load_specific_level", "return", path)
		return

	# Ensure we aren't carrying over old state when jumping to a specific level
	if M_GameState.has_game_state():
		M_GameState.reset()

	GlobalSignal.SIG_show_tut.emit()
	M_SceneLoader.load_scene(path)
		
func load_game_scene() -> void:
	_reset_audio_state()
	
	M_GameState.start_game()
	if signal_game_start:
		M_SceneLoader.load_scene(game_scene_path, true)
		SIG_game_started.emit()
	else:
		M_SceneLoader.load_scene(game_scene_path)

func new_game() -> void:
	if confirm_new_game and M_GameState.has_game_state():
		%NewGameConfirmationDialog.popup_centered()
	else:
		M_GameState.reset()
		load_game_scene()

func exit_game() -> void:
	if signal_game_exit:
		game_exited.emit()
	else:
		get_tree().quit()


func _reset_audio_state() -> void:
	if effect:
		effect.cutoff_hz = START_MAIN_MENU_TRACK_CUTOFF

## SHOW/HIDE menu
# region

func _hide_menu() -> void:
	back_button.show()
	menu_container.hide()

func _show_menu() -> void:
	back_button.hide()
	menu_container.show()

func _open_sub_menu(menu: Control) -> void:
	sub_menu = menu
	sub_menu.show()
	_hide_menu()
	sub_menu_opened.emit()

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	_show_menu()
	sub_menu_closed.emit()

# endregion


func _event_is_mouse_button_released(event: InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()


func _add_or_hide_options() -> void:
	if options_packed_scene == null:
		options_button.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		options_container.show()
		options_container.call_deferred("add_child", options_scene)


func _add_or_hide_credits() -> void:
	if credits_packed_scene == null:
		credits_button.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		credits_container.show()
		credits_container.call_deferred("add_child", credits_scene)


## ON BUTTON PRESSED
# region


func _on_level_1_button_pressed() -> void:
	_load_specific_level(level_1_scene_path)

func _on_level_2_button_pressed() -> void:
	_load_specific_level(level_2_scene_path)


func _on_new_game_button_pressed() -> void:
	new_game()
	

func _on_continue_game_button_pressed() -> void:
	M_GameState.continue_game()
	load_game_scene()

func _on_new_game_confirmation_dialog_confirmed() -> void:
	M_GameState.reset()
	load_game_scene()


func _on_options_button_pressed() -> void:
	_open_sub_menu(options_scene)

func _on_credits_button_pressed() -> void:
	_open_sub_menu(credits_scene)

func _on_exit_button_pressed() -> void:
	exit_game()

func _on_credits_end_reached() -> void:
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed() -> void:
	_close_sub_menu()

# endregion


## to override
func __LOG_B() -> bool:
	return LogToggler.UI.MAIN_MENU
