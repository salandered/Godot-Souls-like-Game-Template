extends Node3DLogger


## Autoload ##

@onready var tutorial_overlay: TutorialOverlay = %TutorialOverlay

@onready var control_info: Label = %ControlInfo
@onready var profiler_info: Label = %ProfilerInfo
@onready var panel_container: PanelContainer = %ProfilerPanel
@onready var tutorial_panel: PanelContainer = %TutorialPanel
@onready var legend: MarginContainer = %Legend
@onready var tutorial_labels: VBoxContainer = %TutorialLabels

var control_info_text := "F3 - toggle mode: transparent - solid - hidden"

# 0 = Transparent, 1 = Solid, 2 = Hidden
var display_state: int = 0

func _ready() -> void:
	control_info.text = control_info_text # Fixed typo "rext"
	update_display_mode()
	__log_("_ready of profiler")
	GlobalSignal._SIG_show_tut.connect(_on_show_tutorial)
	GlobalSignal._SIG_hid_tut.connect(_on_hide_tutorial)
	_on_hide_tutorial()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_profiler):
		cycle_display_mode()

	# Optimization: Don't calculate strings if UI is hidden (State 2)
	if display_state == 2:
		return

	var fps = Engine.get_frames_per_second()
	
	var vsync_mode = DisplayServer.window_get_vsync_mode()
	var mode_name = "Unknown"
	match vsync_mode:
		DisplayServer.VSYNC_DISABLED: mode_name = "Disabled"
		DisplayServer.VSYNC_ENABLED: mode_name = "Enabled (Std)"
		DisplayServer.VSYNC_ADAPTIVE: mode_name = "Adaptive"
		DisplayServer.VSYNC_MAILBOX: mode_name = "Mailbox"
	
	var mem = OS.get_static_memory_usage() / 1048576.0
	
	profiler_info.text = "FPS: %d\nVSync: %s\nMemory: %3.0f MiB" % [fps, mode_name, mem]


func cycle_display_mode() -> void:
	display_state = (display_state + 1) % 3
	update_display_mode()


func update_display_mode() -> void:
	match display_state:
		0: # Show (Transparent Background)
			panel_container.visible = true
			panel_container.self_modulate.a = 0.0 # Hide the panel style, keep text
		1: # Show (Solid Background)
			panel_container.visible = true
			panel_container.self_modulate.a = 1.0 # Show panel style
		2: # Hide
			panel_container.visible = false


func pp_name() -> String:
	return pp.s("~~~", u.construct_obj_pp_name(self))


func _on_show_tutorial():
	tutorial_panel.visible = true
	tutorial_labels.visible = true
	legend.visible = true
	# tutorial_overlay.hide_all()


func _on_hide_tutorial():
	tutorial_panel.visible = false
	# tutorial_overlay.hide_all()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_0:
		tutorial_labels.visible = not tutorial_labels.visible
