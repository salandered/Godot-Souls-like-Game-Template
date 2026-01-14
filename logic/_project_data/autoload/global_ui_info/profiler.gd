extends Node
class_name Profiler

@onready var control_info: Label = %ProfilerControlInfo
@onready var profiler_info: Label = %ProfilerInfo
@onready var profiler_panel: PanelContainer = %ProfilerPanel
@onready var control_info_box: VBoxContainer = %ControlInfoBox


var control_info_text := "F3 - toggle: show/minimal/hide"


func _ready() -> void:
	if control_info:
		control_info.text = control_info_text


func _process(_delta: float) -> void:
	var fps := Engine.get_frames_per_second()
	
	var vsync_mode := DisplayServer.window_get_vsync_mode()
	var mode_name := "Unknown"
	match vsync_mode:
		DisplayServer.VSYNC_DISABLED: mode_name = "Disabled"
		DisplayServer.VSYNC_ENABLED: mode_name = "Enabled (Std)"
		DisplayServer.VSYNC_ADAPTIVE: mode_name = "Adaptive"
		DisplayServer.VSYNC_MAILBOX: mode_name = "Mailbox"
	
	var mem := OS.get_static_memory_usage() / 1048576.0
	
	if profiler_info:
		profiler_info.text = "FPS: %d\nVSync: %s\nMemory: %3.0f MiB" % [fps, mode_name, mem]


func show_profiler(minimal: bool) -> void:
	if profiler_panel:
		profiler_panel.visible = true
		profiler_panel.self_modulate.a = 0.0 if minimal else 1.0
		control_info_box.visible = not minimal


func hide_profiler() -> void:
	if profiler_panel:
		profiler_panel.visible = false
