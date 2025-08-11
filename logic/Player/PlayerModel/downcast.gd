extends RayCast3D

@export var root_attachment : BoneAttachment3D
@export var is_player: bool = false
@onready var csg_sphere_3d = $CSGSphere3D

func _ready():
	if is_player:
		collision_mask = Collision.Layers.ENVIRONMENT_COL
	else:
		collision_mask = Collision.Layers.ENVIRONMENT_COL

func _process(delta):
	# print(root_attachment.global_position)
	global_position = root_attachment.global_position
	csg_sphere_3d.global_position = get_collision_point()

	# if is_player:
	# 	print("is player ", is_player)
	# 	print("Collision Point: ", get_collision_point())
	# 	print_.collisions(self, 3, false)
	
