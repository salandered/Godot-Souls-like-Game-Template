extends Node
class_name FreeCamUI

@onready var controls_info: MarginContainer = %ControlsInfo
@onready var controls: RichTextLabel = %Controls
@onready var hud_info: MarginContainer = %HUDInfo
@onready var hud: RichTextLabel = %HUD
@onready var free_cam: MarginContainer = %FreeCam


var ENABLED: bool = false


const controls_text := "[b]WASD[/b] - Move
[b]Q/E[/b] - Down/Up
[b]Shift[/b] - Speed boost
[b]L[/b] - Light on/off
[b]P[/b] - Unpause/pause scene
[b]Wheel up/down[/b] - Change speed
[b]Wheel up/down + RMB[/b] - Change FOV
[b]Wheel up/down + LMB[/b] - Change light energy
[i]NumPad 0 - Toggle ui modes[/i]
"

func _ready() -> void:
	if controls:
		controls.text = controls_text
	set_free_cam_enable(false)


var free_cam_label_visibility_cycler := Cycler.new([
		[true, true],
		[false, true],
		[false, false],
	],
	0
)

func update_free_cam_hud(text: String):
	if hud:
		hud.text = text


func _cycle_free_cam_labels_visible(next: bool):
	var value
	
	if next:
		value = free_cam_label_visibility_cycler.get_next()
	else:
		value = free_cam_label_visibility_cycler.get_current()
	
	_set_labels_visible(value)


func _set_labels_visible(value: Array):
	if not value or value is not Array or len(value) != 2:
		return

	if not value[0] and not value[1]:
		free_cam.visible = false
	else:
		free_cam.visible = true
		
	if controls_info:
		controls_info.visible = value[0]
	if hud_info:
		hud_info.visible = value[1]


func set_free_cam_enable(toggle: bool) -> void:
	ENABLED = toggle
	free_cam.visible = toggle


func _input(event: InputEvent) -> void:
	if not ENABLED:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_KP_0:
		_cycle_free_cam_labels_visible(true)
