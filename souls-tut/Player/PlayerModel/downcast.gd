extends RayCast3D

@export var root_attachment : BoneAttachment3D

@onready var csg_sphere_3d = $CSGSphere3D

func _process(delta):
	# print(root_attachment.global_position)
	global_position = root_attachment.global_position
	csg_sphere_3d.global_position = get_collision_point()
