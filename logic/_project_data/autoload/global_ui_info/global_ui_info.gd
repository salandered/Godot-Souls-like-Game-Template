extends Node3DLogger

## Autoload ##

@export var in_game_vp_scene: PackedScene

@onready var profiler: Profiler = %Profiler
@onready var first_tutorial: Control = %FirstTutorial
@onready var free_cam_ui: FreeCamUI = %FreeCamUI
@onready var sig_info_manager: SigInfoManager = %SigInfoManager
@onready var error_log_panel_manager: ErrorLogPanelManager = %ErrorLogPanelManager

@onready var dynamic_info_presenters: Node = %DynamicInfoPresenters
@onready var dynamic_info_grid: FlowContainer = %DynamicInfoGrid


const DEF_DYNAMIC_GRID_V_SEP: int = 10
const DEF_SIG_DEBUG: bool = false
const DEF_ERROR_LOG: bool = false
var __SIG_DEBUG: bool = DEF_SIG_DEBUG
var __ERROR_LOG: bool = DEF_ERROR_LOG


var _active_subvp: InGameSubViewport

var _presenters: Array[BaseInfoGroupPresenter]

# 0 = Show, 1 = Minimal, 2 = Off
var profiler_mode_cycler := Cycler.new([0, 1, 2])


var _dev_visual_config: DevVisualsConfig


func get_dev_visuals_config() -> DevVisualsConfig:
	return _dev_visual_config


signal SIG_dvc_value_changed(payload: Dictionary[String, Variant])
signal SIG_dvc_overlay_ui_panel_toggled(payload: Dictionary[String, Variant])
signal SIG_dvc_matrix_cdv_toggled(payload: Dictionary[String, Variant])


func _ready() -> void:
	_dev_visual_config = DevVisualsConfig.new(SIG_dvc_value_changed, SIG_dvc_overlay_ui_panel_toggled, SIG_dvc_matrix_cdv_toggled)


	_presenters.clear()
	for item in dynamic_info_presenters.get_children():
		if item is BaseInfoGroupPresenter:
			_presenters.append(item)

	for item in _presenters:
		if item:
			item.set_enable(false)

	update_profiler_mode(2)

	sig_info_manager.set_enable(DEF_SIG_DEBUG)
	error_log_panel_manager.set_enable(DEF_ERROR_LOG)

	ControlUtils.flow_container_set_v_separation(dynamic_info_grid, DEF_DYNAMIC_GRID_V_SEP)

	SigUtils.safe_connect_pairs([
		[GlobalSignal.SIG_free_cam_mode_toggled, _on_SIG_toggle_free_cam],
		[SIG_dvc_value_changed, _on_SIG_dvc_value_changed],
		[SIG_dvc_overlay_ui_panel_toggled, _on_dvc_SIG_overlay_ui_panel_toggled],
		[SIG_dvc_matrix_cdv_toggled, _on_dvc_SIG_matrix_cdv_toggled]
	])


func _on_SIG_dvc_value_changed(payload: Dictionary[String, Variant]):
	var parsed_payload := SigUtils.safe_get_SIG_dvc_value_changed_payload(payload)
	if not parsed_payload:
		return
	if parsed_payload.value_type == DevVisualsConfig.ValueType.GRID_V_SEP and (parsed_payload.value is int or parsed_payload.value is float):
		var new_value: int = int(parsed_payload.value)
		ControlUtils.flow_container_set_v_separation(dynamic_info_grid, new_value)
		__log_("dynamic_info_grid updated with v_separation", new_value)


func _on_dvc_SIG_overlay_ui_panel_toggled(payload: Dictionary[String, Variant]):
	__log_("_on_dvc_SIG_overlay_ui_panel_toggled", payload)
	var _r_toggle := SigUtils.safe_get_toggle_payload_value(payload)
	if _r_toggle.err:
		return
	
	var _r_type := SigUtils.safe_get_int_payload_value(payload, SPS.dvc_overlay_panel_type_field)
	if _r_type.err:
		return
	
	var toggle := _r_toggle.value
	
	match _r_type.value:
		DevVisualsConfig.OverlayPanelType.TUT:
			_toggle_tutorial_from_dvc(toggle)
		DevVisualsConfig.OverlayPanelType.PROFILER:
			update_profiler_mode(0 if toggle else 2)
		DevVisualsConfig.OverlayPanelType.CAM_NODES:
			_toggle_in_game_subvp_from_dvc(toggle)
		DevVisualsConfig.OverlayPanelType.SIG_DEBUG:
			__SIG_DEBUG = toggle
			sig_info_manager.set_enable(toggle)
		DevVisualsConfig.OverlayPanelType.ERROR_LOG:
			__ERROR_LOG = toggle
			error_log_panel_manager.set_enable(toggle)


func _on_dvc_SIG_matrix_cdv_toggled(payload: Dictionary[String, Variant]):
	__log_("_on_dvc_SIG_matrix_cdv_toggled", payload)
	var _r := SigUtils.safe_get_SIG_matrix_cdv_toggled_payload(payload)
	if not _r:
		return
	for item in _presenters:
		if item.get_char_type() == _r.char_type and item.get_dv_type() == _r.dv_type:
			item.set_enable(_r.toggle)
			return


## SUB VIEWPORT
# region


func _toggle_in_game_subvp_from_dvc(value: bool) -> void:
	var level = Groups.get_level_by_group(self )
	var player := Groups.get_player_by_group(self )
	if not level or not player:
		__log_warn_soft("level or player is invalid")
		return

	if value:
		if not in_game_vp_scene:
			__log_warn("not in_game_vp_scene")
			return
		if _active_subvp:
			__log_("_toggle_in_game_subvp_from_dvc", "_active_subvp is already active")
			return

		var _scene = in_game_vp_scene.instantiate()
		if not _scene is InGameSubViewport:
			__log_warn("not _scene is InGameSubViewport", "_toggle_in_game_subvp_from_dvc")
			return
		_active_subvp = _scene
		
		level.add_child(_active_subvp)
		_active_subvp.set_cam_target(player) # after add_child (so after _ready)
		
	else:
		if not _active_subvp:
			return
		
		_active_subvp.queue_free()
		_active_subvp = null


func is_in_game_subvp_active() -> bool:
	return true if _active_subvp else false


# endregion


## PROFILER UI
# region


func update_profiler_mode(override_mode: int = -1) -> void:
	if not profiler: return

	if override_mode != -1:
		profiler_mode_cycler.force_cycle_to(override_mode)
	match profiler_mode_cycler.get_current():
		0: # Show
			profiler.set_process(true)
			profiler.show_profiler(false)
		1: # Show (minimal)
			profiler.set_process(true)
			profiler.show_profiler(true)
		2: # Hide
			profiler.set_process(false)
			profiler.hide_profiler()


func is_profiler_visible() -> bool:
	return profiler_mode_cycler.get_current() in [0, 1]

# endregion


## FREE CAMERA UI
# region


func update_free_cam_hud(text: String):
	if free_cam_ui:
		free_cam_ui.update_free_cam_hud(text)


func _on_SIG_toggle_free_cam(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, SPS.toggle_field)
	if _r.err: return
	if free_cam_ui:
		free_cam_ui.set_free_cam_enable(_r.value)

# endregion


## FIRST TUTORIAL UI
# region

func _toggle_tutorial_from_dvc(toggle: bool):
	if not first_tutorial:
		return
	
	first_tutorial.set_tutorial_enable(toggle)


func toggle_tutorial(toggle: bool):
	_dev_visual_config.set_active_global_ui_panel(DevVisualsConfig.OverlayPanelType.TUT, toggle)
	

func is_tut_visible() -> bool:
	return first_tutorial.is_visible() if first_tutorial else false
		
# endregion


## PAUSE MENU SETTINGS
# persistence during level run
# region


var ui_overlay_controls_visible: bool = false


# endregion

## Input


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_profiler):
		profiler_mode_cycler.get_next()

		## currently we need to update config instead of changing config which would trigger the UI update.
		## this is because config supports profiler as a bool value, while here we iterate through the different modes
		## legacy issue, should be solved via supporting non binary values in config
		_dev_visual_config.set_active_global_ui_panel(
			DevVisualsConfig.OverlayPanelType.PROFILER,
			true if profiler_mode_cycler.get_current() in [0, 1] else false,
			false ## dont spawn signal
			)
		update_profiler_mode()
		get_viewport().set_input_as_handled()

	# if event.is_action_pressed(RawAction.DEV_show_col):
	# 	var tree := get_tree()
	# 	tree.debug_collisions_hint = not tree.debug_collisions_hint

	# 	get_viewport().set_input_as_handled()

## 

func pp_name() -> String:
	return pp.s("~~~GlobalUI", ObjUtils.construct_obj_pp_name(self ))
