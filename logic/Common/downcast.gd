extends RayCast3D

@export var bone_attachment : BoneAttachment3D
#@export var is_player: bool = false
@onready var csg_sphere_3d = $CSGSphere3D
@export var __csg_visuals : bool = false


## TROUBLESHOOTING: 
##  - bone_attachment should be bone like Hips and correctly identified
##  - after changing Skeleton, bone attachments could bug without reassigning their bones.


func _ready():
	collision_mask = Collision.Layers.ENVIRONMENT_COL

func _process(delta):
	global_position = bone_attachment.global_position
	
	if __csg_visuals:
		csg_sphere_3d.visible = true
		csg_sphere_3d.global_position = get_collision_point()
