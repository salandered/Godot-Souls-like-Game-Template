extends Node3DLogger

## Autoload ##


@onready var profiler: Profiler = %Profiler
@onready var first_tutorial: FirstTutorial = %FirstTutorial
@onready var free_cam_ui: FreeCamUI = %FreeCamUI


# 0 = Show, 1 = Minimal, 2 = Off
var profiler_mode_cycler = Cycler.new([0, 1, 2], 2)

func _ready() -> void:
	GlobalSignal.SIG_show_tut.connect(_on_show_tutorial)
	GlobalSignal.SIG_hid_tut.connect(_on_hide_tutorial)
	GlobalSignal.SIG_show_free_cam_ui.connect(_on_show_free_cam)
	GlobalSignal.SIG_hide_free_cam_ui.connect(_on_hide_free_cam)
	

	update_profiler_mode()


## PROFILER UI
# region

func update_profiler_mode() -> void:
	if not profiler: return
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


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_profiler):
		profiler_mode_cycler.get_next()
		update_profiler_mode()

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


## FIRST TUTORIAL UI
# region

func _on_show_tutorial():
	if first_tutorial:
		first_tutorial.enable_tutorial()

func _on_hide_tutorial():
	if first_tutorial:
		first_tutorial.disable_tutorial()


# endregion


## 

func pp_name() -> String:
	return pp.s("~~~GlobalUI", u.construct_obj_pp_name(self))
