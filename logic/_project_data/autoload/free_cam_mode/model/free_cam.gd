extends Camera3D
class_name FreeCamera


@onready var spot_light_3d: SpotLight3D = %SpotLight3D
@onready var camera_body: FreeCameraBody = %CameraBody


func _ready() -> void:
	camera_body.collision_layer = Collision.Layers.PLAYER_COL
	camera_body.collision_mask = 0
	
func get_light() -> SpotLight3D:
	return spot_light_3d

func get_body() -> FreeCameraBody:
	return camera_body
