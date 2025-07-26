extends BasePlayerState

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# todo
@onready var downcast = $"../../Downcast"
@onready var root_attachment = $"../../Root" # root bone

@export var DELTA_VECTOR_LENGTH = 0.1
var jump_direction: Vector3

var landing_height: float = 1.163


func default_lifecycle(_input: InputPackage):
	var floor_point = downcast.get_collision_point()
	if root_attachment.global_position.distance_to(floor_point) < landing_height:
		var xz_velocity = player.velocity
		xz_velocity.y = 0
		if xz_velocity.length_squared() >= 10:
			return "landing_sprint"
		return "landing_run"
	else:
		# still falling
		return "okay"


func update(_input: InputPackage, _delta):
	var _velocity := velocity_by_input(_input, _delta)
	rotate_player(_velocity, _delta)
	player.velocity.y -= gravity * _delta
	player.move_and_slide()

## Divide velocity and look direction
func rotate_player(_velocity: Vector3, delta: float):
	var input_direction := _velocity.normalized()
	var input_delta_vector = input_direction * DELTA_VECTOR_LENGTH
	
	jump_direction = (jump_direction + input_delta_vector).limit_length(player.velocity.length())
	player.look_at(player.global_position - jump_direction)
	
	var new_velocity = (player.velocity + input_delta_vector).limit_length(player.velocity.length())
	player.velocity = new_velocity

func on_enter_state():
	jump_direction = Vector3(player.basis.z) * clamp(player.velocity.length(), 1, 999999)
	jump_direction.y = 0