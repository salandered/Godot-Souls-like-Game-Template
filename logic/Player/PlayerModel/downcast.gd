extends RayCast3D

@export var root_attachment : BoneAttachment3D
@export var is_player: bool = false
@onready var csg_sphere_3d = $CSGSphere3D

func _process(delta):
	# print(root_attachment.global_position)
	if not is_player:
		collision_mask = Collision.Mask.OTHER_CHAR_COL
	
	global_position = root_attachment.global_position
	csg_sphere_3d.global_position = get_collision_point()
