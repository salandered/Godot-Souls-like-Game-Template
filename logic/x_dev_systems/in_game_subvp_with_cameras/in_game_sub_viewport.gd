class_name InGameSubViewport
extends NodeSystem


@onready var small_cams_container: HBoxContainer = %SmallCamsContainer

@onready var small_top_down_svp: SubViewport = %SmallTopDownSVP
@onready var small_top_down_cam: DebugCoolCamera = %SmallTopDown
@onready var small_left_svp: SubViewport = %SmallLeftSVP
@onready var small_left_cam: DebugCoolCamera = %SmallLeft


@onready var sub_view_container: MarginContainer = %SubViewContainer
@onready var right_sub_viewport: SubViewport = %RightSubViewport
@onready var info_container: MarginContainer = %InfoContainer

@onready var debug_cool_cam: DebugCoolCamera = %DebugCoolCam


@onready var cam_state_label: RichTextLabel = %CamStateLabel

@onready var controls_info: RichTextLabel = %ControlsInfoLabel


var DEF_H_SIZE: float = 800


func __hard_dependencies() -> Array:
	return [
		right_sub_viewport,
		debug_cool_cam
	]

func __soft_dependencies() -> Array:
	return [
		small_top_down_svp,
		small_left_svp,
		small_top_down_cam,
		small_left_cam,
	]


func _ready() -> void:
	if not __perform_validation(true):
		__log_warn_soft("won't be working")
		return

	set_visible(true)
	debug_cool_cam.set_camera_enabled(true, true)


	if small_top_down_cam:
		small_top_down_cam.set_camera_enabled(true, false)
	if small_left_cam:
		small_left_cam.set_camera_enabled(true, false)


	right_sub_viewport.audio_listener_enable_3d = false
	right_sub_viewport.audio_listener_enable_2d = false
	_configure_low_graphics(right_sub_viewport, false)

	
	if small_top_down_svp:
		small_top_down_svp.audio_listener_enable_3d = false
		small_top_down_svp.audio_listener_enable_2d = false
		_configure_low_graphics(small_top_down_svp)
	if small_left_svp:
		small_left_svp.audio_listener_enable_3d = false
		small_left_svp.audio_listener_enable_2d = false
		_configure_low_graphics(small_left_svp)
	

	if controls_info:
		var _r_text := debug_cool_cam.CONTROLS_TEXT
		_r_text += "\n[b]M[/b] - toggle small top views"
		controls_info.text = debug_cool_cam.CONTROLS_TEXT


	set_h_size(DEF_H_SIZE)


func _configure_low_graphics(vp: SubViewport, scaling_3d_scale_: bool = true) -> void:
	if not vp: return

	if scaling_3d_scale_:
		vp.scaling_3d_scale = 0.5
	
	vp.msaa_3d = Viewport.MSAA_DISABLED
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	vp.use_taa = false
	# vp.use_debanding = false
	# vp.use_occlusion_culling = false
	
	vp.mesh_lod_threshold = 4.0

	vp.positional_shadow_atlas_size = 512
	vp.positional_shadow_atlas_16_bits = false


func set_h_size(value: float):
	if not __validation_ok(): return
	sub_view_container.custom_minimum_size = Vector2(value, sub_view_container.custom_minimum_size.y)


func set_visible(value: bool):
	if not __validation_ok(): return
	sub_view_container.visible = value


## TOP DOWN CAM

func _process(delta: float) -> void:
	if debug_cool_cam:
		cam_state_label.text = debug_cool_cam.get_status_text().strip_edges()


func set_cam_target(target: Node3D):
	if not __validation_ok(): return
	if target and is_instance_valid(target) and not target.is_queued_for_deletion():
		debug_cool_cam.target = target
		if small_top_down_cam:
			small_top_down_cam.target = target
		if small_left_cam:
			small_left_cam.target = target
	else:
		__log_warn_soft("can't set cam target, target is invalid")


func _input(event: InputEvent) -> void:
	match InputUtils.get_keycode(event):
		KEY_M:
			small_cams_container.visible = not small_cams_container.visible
			InputUtils.mark_input_handled(self )
