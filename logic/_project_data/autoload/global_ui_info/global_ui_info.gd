extends Node3DLogger

## Autoload ##


@onready var profiler: Profiler = %Profiler
@onready var first_tutorial: FirstTutorial = %FirstTutorial
@onready var free_cam_ui: FreeCamUI = %FreeCamUI

@onready var dynamic_info_distributor: PlayerDynamicInfoDistributor = %DynamicInfoDistributor
@onready var phe_dynamic_info_distributor: PheDynamicInfoDistributor = %PheDynamicInfoDistributor


# 0 = Show, 1 = Minimal, 2 = Off
var profiler_mode_cycler := Cycler.new([0, 1, 2], 2)

func _ready() -> void:
	GlobalSignal.SIG_toggle_show_tut.connect(_on_SIG_toggle_show_tutorial)
	GlobalSignal.SIG_toggle_show_profiler.connect(_on_SIG_toggle_show_profiler)
	GlobalSignal.SIG_show_free_cam_ui.connect(_on_show_free_cam)
	GlobalSignal.SIG_hide_free_cam_ui.connect(_on_hide_free_cam)
	GlobalSignal.SIG_toggle_dynamic_state_info.connect(_on_SIG_toggle_dynamic_state_info)
	GlobalSignal.SIG_toggle_phe_dynamic_state_info.connect(_on_SIG_toggle_phe_dynamic_state_info)

	if dynamic_info_distributor:
		dynamic_info_distributor.set_enable(false)
	if phe_dynamic_info_distributor:
		phe_dynamic_info_distributor.set_enable(false)

	update_profiler_mode()


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


func _on_SIG_toggle_show_profiler(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, GlobalSignal.payload_toggle_field)
	if _r.err: return

	update_profiler_mode(0 if _r.value else 2)


func is_profiler_visible() -> bool:
	return profiler_mode_cycler.get_current() in [0, 1]

# endregion


## FREE CAMERA UI
# region


func update_free_cam_hud(text: String):
	if free_cam_ui:
		free_cam_ui.update_free_cam_hud(text)

func _on_show_free_cam():
	if free_cam_ui:
		free_cam_ui.enable_free_cam()

func _on_hide_free_cam():
	if free_cam_ui:
		free_cam_ui.disable_free_cam()

# endregion


## DYNAMIC INFO CAMERA UI
# region


func _on_SIG_toggle_dynamic_state_info(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, GlobalSignal.payload_toggle_field)
	if _r.err: return
	if dynamic_info_distributor:
		dynamic_info_distributor.set_enable(_r.value)
		if _r.value and phe_dynamic_info_distributor:
			phe_dynamic_info_distributor.set_enable(false)

func _on_SIG_toggle_phe_dynamic_state_info(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, GlobalSignal.payload_toggle_field)
	if _r.err: return
	if phe_dynamic_info_distributor:
		phe_dynamic_info_distributor.set_enable(_r.value)
		if _r.value and dynamic_info_distributor:
			dynamic_info_distributor.set_enable(false)


func is_dynamic_state_info_visible() -> bool:
	return dynamic_info_distributor.is_visible()

func is_phe_dynamic_state_info_visible() -> bool:
	return phe_dynamic_info_distributor.is_visible()
# endregion


## FIRST TUTORIAL UI
# region

func _on_SIG_toggle_show_tutorial(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, GlobalSignal.payload_toggle_field)
	if _r.err: return

	if not first_tutorial:
		return
	
	first_tutorial.set_tutorial_enable(_r.value)


func is_tut_visible() -> bool:
	return first_tutorial.is_visible() if first_tutorial else false
		
# endregion


## PAUSE MENU SETTINGS
# persistence during level run
# region


var ui_overlay_controls_visible: bool = false


# endregion

## Input


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_profiler):
		profiler_mode_cycler.get_next()
		update_profiler_mode()


	if event.is_action_pressed(RawAction.DEV_show_col):
		var tree := get_tree()
		tree.debug_collisions_hint = not tree.debug_collisions_hint


## 

func pp_name() -> String:
	return pp.s("~~~GlobalUI", ObjUtils.construct_obj_pp_name(self))
