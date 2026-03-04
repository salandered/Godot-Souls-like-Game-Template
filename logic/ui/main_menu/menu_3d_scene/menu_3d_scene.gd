@tool
@icon("res://-assets-/x_icons/level/icon_level_purple.png")

class_name Menu3DLevel
extends BaseLevel

@onready var camera_3d: Camera3D = %Camera3D

@export_group("Camera Animation")
@export var cam_z_min: float = 4.0
@export var cam_z_max: float = 6.0
@export var cam_duration: float = 10.0

@export_group("Parallax Effect")
## rotation intensity in radians
@export var parallax_strength: float = 0.05
## smoothing speed
@export var parallax_lerp_speed: float = 5.0
## look up/down
@export_range(-90.0, 90.0) var camera_base_pitch: float = 10.0

## sitting skeleton (experiment)
@onready var skeleton_scene: Skeleton1607Wrapper = %"skeleton-16-07"
@onready var sitting_scene: SittingSceneWrapper = %sitting2


func __hard_dependencies() -> Array:
	return [
		camera_3d
	]

func __soft_dependencies() -> Array:
	return [
		skeleton_scene,
		sitting_scene
	]


func basic_tonemap_exposure() -> float:
	return 1.05


func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.3


func initialize():
	camera_3d.current = true
	_sit_skeleton()

	if __perform_validation(true):
		_start_camera_sway()


func _process(delta: float) -> void:
	_handle_parallax(delta)


func _handle_parallax(delta: float) -> void:
	if not camera_3d:
		return

	var mouse_pos := get_viewport().get_mouse_position()
	var screen_size := get_viewport().get_visible_rect().size

	# center offset (-0.5 to 0.5)
	var center_offset_x := (mouse_pos.x / screen_size.x) - 0.5
	var center_offset_y := (mouse_pos.y / screen_size.y) - 0.5

	# interpolate current rotation towards target rotation
	var target_rot_y := -center_offset_x * parallax_strength
	
	# convert the base pitch from degrees to radians and add the mouse offset
	var target_rot_x := deg_to_rad(camera_base_pitch) + (-center_offset_y * parallax_strength)

	camera_3d.rotation.y = lerp(camera_3d.rotation.y, target_rot_y, delta * parallax_lerp_speed)
	camera_3d.rotation.x = lerp(camera_3d.rotation.x, target_rot_x, delta * parallax_lerp_speed)


func _start_camera_sway() -> void:
	if not camera_3d:
		return
	
	camera_3d.position.z = cam_z_min
	
	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Move to Max
	tween.tween_property(camera_3d, PropC.POSITION_Z, cam_z_max, cam_duration)
	# Move back and some other logic
	tween.tween_property(camera_3d, PropC.POSITION_Z, cam_z_min + 23, cam_duration)
	tween.tween_property(camera_3d, PropC.POSITION_Z, cam_z_max, cam_duration)
	tween.tween_property(camera_3d, PropC.POSITION_Z, cam_z_min + 23, cam_duration)


## as an experiment
func _sit_skeleton():
	if not skeleton_scene:
		__log_warn("no scene skeleton_scene provided", "", "will do nothing")
		return
	if not sitting_scene:
		__log_warn("no scene sitting_scene provided", "", "will do nothing")
		return
		
	var skeleton_mesh := skeleton_scene.get_skeleton_mesh()
	var general_skeleton := sitting_scene.get_general_skeleton()
	var anim_player := sitting_scene.get_animation_player()
	if not general_skeleton:
		__log_warn("no general_skeleton", "", "will do nothing")
		return
	if not skeleton_mesh:
		__log_warn("no skeleton_mesh", "", "will do nothing")
		return
	if not anim_player:
		__log_warn("no anim_player", "", "will do nothing")
		return

	skeleton_mesh.skeleton = general_skeleton.get_path()
	var available_anims := anim_player.get_animation_list()
	
	if error_.empty_list(available_anims, pp.s("no available_anims", "", "will do nothing")):
		return
	
	for anim_id: StringName in available_anims:
		__log_("menu3dScene", pp.s("available anim for sitting skeleton:", anim_id))
	
	anim_player.play(available_anims[0])


## __LOGS
# region

func __LOG_B() -> bool:
	return false

# endregion
