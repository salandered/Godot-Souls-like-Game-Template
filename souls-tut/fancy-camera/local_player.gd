extends CharacterBody3D
class_name LocalPlayer

@export var RUN_SPEED: float = 5.0
@onready var fancy_camera: FancyCamera = %FancyCamera
@onready var camera_focus: Node3D = $CameraFocus
var input_data: InputInternal = InputInternal.new()

func _ready() -> void:
	print("LocalPlayer ready")
	print("		root_player ", fancy_camera.root_player)

func _physics_process(delta: float) -> void:
	input_data.update()
	velocity = velocity_by_input(input_data, self, delta)
	move_and_slide()

func velocity_by_input(input: InputInternal, player: CharacterBody3D, delta: float) -> Vector3:
	var _velocity = Vector3.ZERO
	var forward_speed = input.get_forward()
	var orbit_speed = input.get_orbiting()

	if fancy_camera.is_target_locked:
		print("fancy_camera.is_target_locked *= -1")
		forward_speed *= -1
		orbit_speed *= -1

	var grounded_target: Vector3
	if fancy_camera.is_target_locked and fancy_camera.locked_target:
		grounded_target = fancy_camera.locked_target.global_position
	else:
		grounded_target = fancy_camera.camera_nest.global_position
	grounded_target.y = player.global_position.y
	
	if forward_speed != 0.0:
		# var grounded_target := fancy_camera.camera_nest.global_position
		# grounded_target.y = player.global_position.y
		_velocity -= player.global_position.direction_to(grounded_target) * forward_speed * RUN_SPEED

	if orbit_speed != 0.0:
		var d: float = orbit_speed * RUN_SPEED * delta
		# var grounded_target := fancy_camera.camera_nest.global_position
		# grounded_target.y = player.global_position.y

		var target_direction := grounded_target - player.global_position # R1
		var distance_to_target := target_direction.length()
		var alpha = -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha) # R2
		var orb_pt = grounded_target + rotated_dir
		var d_vector := grounded_target - rotated_dir - player.global_position
		_velocity += d_vector / delta

	return _velocity.limit_length(RUN_SPEED)
