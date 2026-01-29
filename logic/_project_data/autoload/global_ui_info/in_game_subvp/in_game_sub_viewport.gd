extends NodeSystem
class_name InGameSubViewport


@onready var sub_view_container: MarginContainer = %SubViewContainer
@onready var right_sub_viewport: SubViewport = %RightSubViewport
@onready var info_container: MarginContainer = %InfoContainer

@onready var top_down_camera: TopDownCamera = %TopDownCamera


const controls_text := "[b]Wheel up/down[/b] - Change top view height
[b]Wheel up/down + RMB[/b] - Change top view FOV
[i]NumPad 0 - Toggle ui[/i]
"


var DEF_H_SIZE: float = 800

func __hard_dependencies() -> Array:
	return [
		right_sub_viewport,
		top_down_camera
	]

func _ready() -> void:
	if not __perform_validation():
		__log_warn_soft("won't be working")
		return

	set_visible(true)
	top_down_camera.set_camera_enabled(true)

	right_sub_viewport.audio_listener_enable_3d = false
	right_sub_viewport.audio_listener_enable_2d = false
	
	set_h_size(DEF_H_SIZE)
	# SigUtils.safe_connect(GlobalSignal.SIG_free_cam_mode_toggled, _on_SIG_free_cam_mode_toggled)

	
# func _on_SIG_free_cam_mode_toggled(payload: Dictionary[String, Variant]):
# 	var _r := SigUtils.safe_get_toggle_payload_value(payload)
# 	if _r.err: return

# 	var toggled: bool = _r.value
# 	set_visible(not toggled)


func set_h_size(value: float):
	if not __validation_ok(): return
	sub_view_container.custom_minimum_size = Vector2(value, sub_view_container.custom_minimum_size.y)


func set_visible(value: bool):
	if not __validation_ok(): return
	sub_view_container.visible = value


func set_cam_target(target: Node3D):
	if not __validation_ok(): return
	if target and is_instance_valid(target) and not target.is_queued_for_deletion():
		top_down_camera.target = target
	else:
		__log_warn_soft("can't set cam target, target is invalid")
