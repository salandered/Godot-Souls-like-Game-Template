extends Node3D

@onready var camera_3d: Camera3D = %Camera3D

@export_group("Camera Animation")
@export var cam_z_min: float = 4.0
@export var cam_z_max: float = 6.0
@export var cam_duration: float = 10.0

@export_group("Parallax Effect")
@export var parallax_strength: float = 0.05 # Rotation intensity in radians
@export var parallax_lerp_speed: float = 5.0 # Smoothing speed
@export_range(-90.0, 90.0) var camera_base_pitch: float = 10.0 # Adjust this to look up/down

## sitting skeleton
@onready var skeleton_scene: Skeleton1607Wrapper = $"skeleton/skeleton-16-07"
@onready var sitting_scene: SittingSceneWrapper = $skeleton/sitting2


func initialise():
	camera_3d.current = true
	_start_camera_sway()
	_sit_skeleton()
	
func _process(delta: float) -> void:
	_handle_parallax(delta)

func _handle_parallax(delta: float) -> void:
	if not camera_3d:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	# Calculate center offset (-0.5 to 0.5)
	var center_offset_x = (mouse_pos.x / screen_size.x) - 0.5
	var center_offset_y = (mouse_pos.y / screen_size.y) - 0.5

	# Smoothly interpolate current rotation towards target rotation
	var target_rot_y = -center_offset_x * parallax_strength
	
	# We convert the base pitch from degrees to radians and add the mouse offset
	var target_rot_x = deg_to_rad(camera_base_pitch) + (-center_offset_y * parallax_strength)

	camera_3d.rotation.y = lerp(camera_3d.rotation.y, target_rot_y, delta * parallax_lerp_speed)
	camera_3d.rotation.x = lerp(camera_3d.rotation.x, target_rot_x, delta * parallax_lerp_speed)



func _start_camera_sway() -> void:
	if not camera_3d:
		return
	
	camera_3d.position.z = cam_z_min
	
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Move to Max
	tween.tween_property(camera_3d, "position:z", cam_z_max, cam_duration)
	# Move back to Min
	tween.tween_property(camera_3d, "position:z", cam_z_min, cam_duration)


func _sit_skeleton():
	if not skeleton_scene:
		print_.warn(false, "no scene skeleton_scene provided", "menu3dScene", "will do nothing")
		return 
	if not sitting_scene:
		print_.warn(false, "no scene sitting_scene provided", "menu3dScene", "will do nothing")
		return 
		
	var skeleton_mesh := skeleton_scene.get_skeleton_mesh()
	var general_skeleton := sitting_scene.get_general_skeleton()
	var anim_player := sitting_scene.get_animation_player()
	if not general_skeleton:
		print_.warn(false, "no general_skeleton", "menu3dScene", "will do nothing")
		return 
	if not skeleton_mesh:
		print_.warn(false, "no skeleton_mesh", "menu3dScene", "will do nothing")
		return
	if not anim_player:
		print_.warn(false, "no anim_player", "menu3dScene", "will do nothing")
		return  

	skeleton_mesh.skeleton = general_skeleton.get_path()
	var available_anims := anim_player.get_animation_list()
	
	if len(available_anims) == 0:
		print_.warn(false, "no available_anims", "menu3dScene", "will do nothing")
		return  
	
	for anim_id: String in available_anims:
		print_.prefix("menu3dScene", pp.s("available anim for sitting skeleton:", anim_id))
	
	anim_player.play(available_anims[0])
	
