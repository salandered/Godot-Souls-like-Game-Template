extends RayCast3D

@export var attachment: Node3D
@onready var csg_sphere_3d := $CSGSphere3D
@export var __csg_visuals: bool = false


## TROUBLESHOOTING: 
##  - attachment should be bone like Hips and correctly identified
##  - after changing Skeleton, bone attachments could bug without reassigning their bones.
##  - for 'Debug Shape' Debug visual options should be checked
##  - if attachment is root, it's better be a bit higher than root. 
##    Otherwise we can sink though the floor

func _ready():
	collision_mask = Collision.Layers.ENVIRONMENT_COL

func _process(delta):
	global_position = attachment.global_position
	
	if __csg_visuals:
		csg_sphere_3d.visible = true
		csg_sphere_3d.global_position = get_collision_point()
