class_name M_AudioOptionsMenu
extends Control

@export var audio_control_scene: PackedScene
@export var hide_busses: Array[StringName]

@onready var mute_control = %MuteControl


func _on_bus_changed(bus_value: float, bus_iter: int) -> void:
	M_AppSettings.set_bus_volume(bus_iter, bus_value)


func _add_audio_control(bus_name: StringName, bus_value: float, bus_iter: int) -> void:
	if audio_control_scene == null \
		or bus_name in hide_busses \
		or bus_name.begins_with(M_AppSettings.SYSTEM_BUS_NAME_PREFIX) \
		or bus_name.begins_with(AudioServerUtil.DEV_BUS_PREFIX) \
		or bus_name.begins_with(AudioServerUtil.TEST_BUS_PREFIX):
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is M_OptionControl:
		audio_control.option_section = M_OptionControl.OptionSections.AUDIO
		audio_control.option_name = bus_name
		audio_control.value = bus_value
		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_iter))


func _add_audio_bus_controls() -> void:
	for bus_iter in AudioServer.bus_count:
		var bus_name: StringName = M_AppSettings.get_audio_bus_name(bus_iter)
		var linear: float = M_AppSettings.get_bus_volume(bus_iter)
		_add_audio_control(bus_name, linear, bus_iter)


func _update_ui() -> void:
	_add_audio_bus_controls()
	mute_control.value = M_AppSettings.is_muted()


func _ready() -> void:
	_update_ui()


func _on_mute_control_setting_changed(value: bool) -> void:
	M_AppSettings.set_mute(value)
