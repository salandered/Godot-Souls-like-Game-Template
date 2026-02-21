class_name M_LoadingScreen
extends CanvasLayerLogger

enum StallStage {STARTED, WAITING, STILL_WAITING, GIVE_UP}


@export_range(5, 60, 0.5, "or_greater") var state_change_delay: float = 15.0
@export_group("State Messages")
@export_subgroup("In Progress")
@export var _in_progress: String = "Loading..."
@export var _in_progress_waiting: String = "Still Loading..."
@export var _in_progress_still_waiting: String = "Still Loading... (%d seconds)"
@export_subgroup("Completed")
@export var _complete: String = "Loading Complete!"
@export var _complete_waiting: String = "Wait for it..."
@export var _complete_still_waiting: String = "Wait for it... (%d seconds)"


var _stall_stage: StallStage = StallStage.STARTED
var _scene_loading_complete: bool = false
var _scene_loading_progress: float = 0.0:
	set(value):
		var _value_changed := _scene_loading_progress != value
		_scene_loading_progress = value
		if _value_changed:
			update_total_loading_progress()
			_reset_loading_stage()
var _total_loading_progress: float = 0.0:
	set(value):
		_total_loading_progress = value
		%ProgressBar.value = _total_loading_progress
var _loading_start_time: int

@export_group("Visuals")
@export_file("*.png", "*.jpg", "*.webp") var background_image_paths: Array[String]
@onready var background_texture_rect: TextureRect = %BackgroundTextureRect


## UI for the asynchronous loading process managed by M_SceneLoader.
## A controller script for a visual, user-facing loading screen.
## It visualizes the loading progress from the M_SceneLoader autoload by updating a progress bar and a text label.
## It features a stall detection system that changes the text message if loading takes an unusually long time to keep the user informed.
## It includes pop-up dialogs to handle cases where loading gets stuck or fails, giving the user options like waiting or restarting.


func _ready() -> void:
	reset()


var _progress_tween: Tween

func update_total_loading_progress() -> void:
	var diff := absf(_scene_loading_progress - _total_loading_progress)
	
	# prevents micro-stuttering
	if diff < 0.01:
		_total_loading_progress = _scene_loading_progress
		return

	# Kill previous animation
	if _progress_tween:
		_progress_tween.kill()
	
	_progress_tween = create_tween()
	
	# ADDED DYNAMIC DURATION
	# If jumping 100% (1.0), take 0.5s.
	# If jumping 10% (0.1), take 0.05s.
	# clamp it to a minimum of 0.1s so it doesn't look too instant
	var duration := maxf(diff * 0.3, 0.1)
	# print_.prefix_s("~~~~", duration)
	_progress_tween.tween_property(self , "_total_loading_progress", _scene_loading_progress, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func _reset_loading_stage() -> void:
	_stall_stage = StallStage.STARTED
	%LoadingTimer.start(state_change_delay)


func _reset_loading_start_time() -> void:
	_loading_start_time = Time.get_ticks_msec()


func _get_seconds_waiting() -> int:
	return int((Time.get_ticks_msec() - _loading_start_time) / 1000.0)


func _update_scene_loading_progress() -> void:
	var new_progress = M_SceneLoader.get_progress()
	if new_progress > _scene_loading_progress:
		_scene_loading_progress = new_progress


func _set_scene_loading_complete() -> void:
	_scene_loading_progress = 1.0
	_scene_loading_complete = true


func _reset_scene_loading_progress() -> void:
	_scene_loading_progress = 0.0
	_scene_loading_complete = false

# error message
# region

func _show_loading_stalled_error_message() -> void:
	if %StalledMessage.visible:
		return
	if _scene_loading_progress == 0:
		%StalledMessage.dialog_text = "Stalled at start. You may try waiting or restarting.\n"
	else:
		%StalledMessage.dialog_text = "Stalled at %d%%. You may try waiting or restarting.\n" % (_scene_loading_progress * 100.0)
	%StalledMessage.popup()


func _show_scene_switching_error_message() -> void:
	if %ErrorMessage.visible:
		return
	%ErrorMessage.dialog_text = "Loading Error: Failed to switch scenes."
	%ErrorMessage.popup()

# endregion

func _hide_popups() -> void:
	%ErrorMessage.hide()
	%StalledMessage.hide()


func get_progress_message() -> String:
	var _progress_message: String
	match _stall_stage:
		StallStage.STARTED:
			if _scene_loading_complete:
				_progress_message = _complete
			else:
				_progress_message = _in_progress
		StallStage.WAITING:
			if _scene_loading_complete:
				_progress_message = _complete_waiting
			else:
				_progress_message = _in_progress_waiting
		StallStage.STILL_WAITING, StallStage.GIVE_UP:
			if _scene_loading_complete:
				_progress_message = _complete_still_waiting
			else:
				_progress_message = _in_progress_still_waiting
	if _progress_message.contains("%d"):
		_progress_message = _progress_message % _get_seconds_waiting()
	return _progress_message


func _update_progress_messaging() -> void:
	%ProgressLabel.text = get_progress_message()
	if _stall_stage == StallStage.GIVE_UP:
		if _scene_loading_complete:
			_show_scene_switching_error_message()
		else:
			_show_loading_stalled_error_message()
	else:
		_hide_popups()


func _process(_delta: float) -> void:
	var status = M_SceneLoader.get_status()
	match (status):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_update_scene_loading_progress()
			_update_progress_messaging()
		ResourceLoader.THREAD_LOAD_LOADED:
			_set_scene_loading_complete()
			_update_progress_messaging()
		ResourceLoader.THREAD_LOAD_FAILED:
			%ErrorMessage.dialog_text = "Loading Error: %d" % status
			%ErrorMessage.popup()
			set_process(false)
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_hide_popups()
			set_process(false)


func _on_loading_timer_timeout() -> void:
	var prev_stage: StallStage = _stall_stage
	match prev_stage:
		StallStage.STARTED:
			_stall_stage = StallStage.WAITING
			%LoadingTimer.start(state_change_delay)
		StallStage.WAITING:
			_stall_stage = StallStage.STILL_WAITING
			%LoadingTimer.start(state_change_delay)
		StallStage.STILL_WAITING:
			_stall_stage = StallStage.GIVE_UP


func _reload_main_scene_or_quit() -> void:
	var err = get_tree().change_scene_to_file(
		ProjectSettings.get_setting(PropC.APPLICATION_RUN_MAIN_SCENE)
	)
	if err:
		push_error("failed to load main scene: %d" % err)
		get_tree().quit()


func _on_error_message_confirmed() -> void:
	_reload_main_scene_or_quit()


func _on_confirmation_dialog_canceled() -> void:
	_reload_main_scene_or_quit()


func _on_confirmation_dialog_confirmed() -> void:
	_reset_loading_stage()


func reset() -> void:
	show()
	__log_("reset", "")

	if _progress_tween:
		_progress_tween.kill()

	_setup_background()

	_reset_loading_stage()
	_reset_scene_loading_progress()
	_reset_loading_start_time()
	_hide_popups()
	set_process(true)


func close() -> void:
	set_process(false)
	_hide_popups()
	hide()


# Background images
# region

func _setup_background() -> void:
	if background_image_paths.size() > 0:
		var random_path = background_image_paths.pick_random()
		
		# Load the texture on demand
		var texture := load(random_path)
		
		if background_texture_rect and texture:
			background_texture_rect.texture = texture
			__log_("Set random background -> ", random_path.get_file())
		else:
			__log_warn("BackgroundTextureRect is null or load failed", "", "")
	else:
		__log_warn("no background_image_paths", "", "")
