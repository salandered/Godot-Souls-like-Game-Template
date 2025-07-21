extends BasePlayerState
class_name MidairState

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# todo
@onready var downcast = $"../../Downcast"
@onready var root_attachment = $"../../Root" # root bone


var landing_height: float = 1.163


func _ready():
	animation = "midair"
	state_name = PlayerState.midair


func check_relevance(_input: InputPackage):
	var floor_point = downcast.get_collision_point()
	if root_attachment.global_position.distance_to(floor_point) < landing_height:
		var xz_velocity = player.velocity; xz_velocity.y = 0
		if xz_velocity.length_squared() >= 10:
			return PlayerState.landing_sprint
		return PlayerState.landing_run
	else:
		# still falling
		return "okay"


func update(input: InputPackage, delta):
	player.velocity.y -= gravity * delta
	player.move_and_slide()
