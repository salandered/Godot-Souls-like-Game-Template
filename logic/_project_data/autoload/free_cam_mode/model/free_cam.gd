extends Camera3D
class_name FreeCamera


@onready var _spot_light_3d: SpotLight3D = %SpotLight3D
@onready var _camera_body: FreeCameraBody = %CameraBody


func _ready() -> void:
	# imitates player
	_camera_body.collision_layer = Collision.Layers.PLAYER_COL
	_camera_body.collision_mask = 0
	

func get_light() -> SpotLight3D:
	return _spot_light_3d


func get_body() -> FreeCameraBody:
	return _camera_body
