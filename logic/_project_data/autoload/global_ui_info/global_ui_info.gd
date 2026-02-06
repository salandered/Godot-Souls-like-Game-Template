extends Node3DLogger

## Autoload ##

@export var in_game_vp_scene: PackedScene

@onready var profiler: Profiler = %Profiler
@onready var first_tutorial: Control = %FirstTutorial
@onready var free_cam_ui: FreeCamUI = %FreeCamUI
@onready var sig_info_manager: SigInfoManager = %SigInfoManager
@onready var all_log_panel_manager: AllLogPanelManager = %AllLogPanelManager
@onready var error_log_panel_manager: ErrorLogPanelManager = %ErrorLogPanelManager

@onready var debug_fancy_cam_panel_manager: DebugFancyCamManager = %DebugFancyCamPanelManager

@onready var dynamic_info_presenters: Node = %DynamicInfoPresenters
@onready var dynamic_info_grid: FlowContainer = %DynamicInfoGrid


const DEF_DYNAMIC_GRID_V_SEP: int = 20
const DEF_SIG_DEBUG: bool = false
const DEF_ALL_LOG: bool = false
const DEF_ERROR_LOG: bool = false
var __SIG_DEBUG: bool = DEF_SIG_DEBUG
var __ALL_LOG: bool = DEF_ALL_LOG
var __ERROR_LOG: bool = DEF_ERROR_LOG


var _active_subvp: InGameSubViewport

var _presenters: Array[BaseInfoGroupPresenter]

# 0 = Show, 1 = Minimal, 2 = Off
var profiler_mode_cycler := Cycler.new([0, 1, 2])


var _dev_visual_config: DevVisualsConfig


func get_dev_visuals_config() -> DevVisualsConfig:
	return _dev_visual_config


signal SIG_dvc_value_changed(payload: Dictionary[String, Variant])
signal SIG_dvc_value_changed_section_op(payload: Dictionary[String, Variant])
signal SIG_dvc_value_changed_section_vc(payload: Dictionary[String, Variant])
signal SIG_dvc_value_changed_section_char_dv(payload: Dictionary[String, Variant])


func _ready() -> void:
	_dev_visual_config = DevVisualsConfig.new(SIG_dvc_value_changed)


	_presenters.clear()
	for item in dynamic_info_presenters.get_children():
		if item is BaseInfoGroupPresenter:
			_presenters.append(item)

	for item in _presenters:
		if item:
			item.set_enable(false)

	update_profiler_mode(2)

	sig_info_manager.set_enable(DEF_SIG_DEBUG)
	all_log_panel_manager.set_enable(DEF_ALL_LOG)
	error_log_panel_manager.set_enable(DEF_ERROR_LOG)

	ControlUtils.flow_container_set_v_separation(dynamic_info_grid, DEF_DYNAMIC_GRID_V_SEP)

	SigUtils.safe_connect_pairs([
		[GlobalSignal.SIG_free_cam_mode_toggled, _on_SIG_toggle_free_cam],
		[SIG_dvc_value_changed, _on_SIG_dvc_value_changed_distribute_signal],
		[SIG_dvc_value_changed_section_op, _on_SIG_dvc_value_changed_section_op],
		[SIG_dvc_value_changed_section_vc, _on_SIG_dvc_value_changed_section_vc],
		[SIG_dvc_value_changed_section_char_dv, _on_SIG_dvc_value_changed_section_char_dv]
	])


## distribution sits here temporary. It should be separated class (it's not about the GlobalUIInfo)
func _on_SIG_dvc_value_changed_distribute_signal(payload: Dictionary[String, Variant]):
	var parsed_payload := SigPayloadParser.safe_get_SIG_dvc_value_changed_payload(payload)
	if not parsed_payload:
		return

	var distributed_payload: Dictionary[String, Variant] = {
		SPS.dvc_key_field: parsed_payload.key,
		SPS.dvc_value_field: parsed_payload.value
	}
	match parsed_payload.section:
		DVS.DVSection.OVERLAY_PANEL:
			SigUtils.safe_emit_raw(SIG_dvc_value_changed_section_op, distributed_payload)
		DVS.DVSection.VALUE_CHANGER:
			SigUtils.safe_emit_raw(SIG_dvc_value_changed_section_vc, distributed_payload)
		DVS.DVSection.CHAR_DV:
			SigUtils.safe_emit_raw(SIG_dvc_value_changed_section_char_dv, distributed_payload)


func _on_SIG_dvc_value_changed_section_vc(payload: Dictionary[String, Variant]):
	var _r := SigPayloadParser.safe_get_value_by_key_from_SIG_dvc_value_changed_section_payload(
		payload,
		DVS.KeyValueChanger.GRID_V_SEP)
	if _r.err or (_r.value is not float and _r.value is not int): return
	var new_value: int = int(_r.value)
	ControlUtils.flow_container_set_v_separation(dynamic_info_grid, new_value)
	__log_("dynamic_info_grid updated with v_separation", new_value)


func _on_SIG_dvc_value_changed_section_op(payload: Dictionary[String, Variant]):
	var _r := SigPayloadParser.safe_get_SIG_dvc_value_changed_section_payload(payload)
	if not _r or _r.value is not bool: return
	var toggle := _r.value as bool
	
	match _r.key:
		DVS.KeyOverlayPanel.TUT:
			_toggle_tutorial_from_dvc(toggle)
		DVS.KeyOverlayPanel.PROFILER:
			update_profiler_mode(0 if toggle else 2)
		DVS.KeyOverlayPanel.SIG_DEBUG:
			__SIG_DEBUG = toggle
			sig_info_manager.set_enable(toggle)
		DVS.KeyOverlayPanel.ALL_LOG:
			__ALL_LOG = toggle
			all_log_panel_manager.set_enable(toggle)
		DVS.KeyOverlayPanel.ERROR_LOG:
			__ERROR_LOG = toggle
			error_log_panel_manager.set_enable(toggle)
		DVS.KeyOverlayPanel.CAM_NODES:
			pass
		DVS.KeyOverlayPanel.SUBVIEWPORT:
			_toggle_in_game_subvp_from_dvc(toggle)


func _on_SIG_dvc_value_changed_section_char_dv(payload: Dictionary[String, Variant]):
	__log_("_on_SIG_dvc_value_changed_section_char_dv", payload)
	var _r := SigPayloadParser.safe_get_SIG_dvc_value_changed_section_payload(payload)
	if not _r or _r.value is not bool: return
	var toggle := _r.value as bool

	for item in _presenters:
		if item.get_composite_dvc_key() == _r.key:
			item.set_enable(toggle)
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
	_dev_visual_config.set_value(DVS.DVSection.OVERLAY_PANEL, DVS.KeyOverlayPanel.TUT, toggle)
	

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
	if event.is_action_pressed(RawAction.DEV_profiler):
		profiler_mode_cycler.get_next()

		## currently we need to update config instead of changing config which would trigger the UI update.
		## this is because config supports profiler as a bool value, while here we iterate through the different modes
		## legacy issue, should be solved via saving not boolean profiler in config
		_dev_visual_config.set_value(
			DVS.DVSection.OVERLAY_PANEL,
			DVS.KeyOverlayPanel.PROFILER,
			true if profiler_mode_cycler.get_current() in [0, 1] else false,
			false ## dont spawn signal
			)
		update_profiler_mode()
		get_viewport().set_input_as_handled()

## 

func pp_name() -> String:
	return pp.s("~~~GlobalUI", ObjUtils.construct_obj_pp_name(self ))


func __LOG_B() -> bool:
	return false
