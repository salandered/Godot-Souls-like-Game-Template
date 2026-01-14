extends RayCast3D

@export var attachment: Node3D
@onready var csg_sphere_3d: CSGSphere3D = $CSGSphere3D
@onready var csg_sphere_3d_2: CSGSphere3D = $CSGSphere3D2
@export var __csg_visuals: bool = false
@export var __log_dist: bool = false


## TROUBLESHOOTING: 
##  - attachment should be bone like Hips or Root and correctly identified
##  - after changing Skeleton, bone attachments could bug without reassigning their bones.
##  - for 'Debug Shape' Debug visual options should be checked
##  - if attachment is Root, it should be a bit higher than that. 

func _ready() -> void:
	collision_mask = Collision.Layers.ENVIRONMENT_COL

func _process(delta: float) -> void:
	global_position = attachment.global_position
	
	if __csg_visuals:
		if csg_sphere_3d:
			csg_sphere_3d.visible = true
		if csg_sphere_3d and csg_sphere_3d_2:
			csg_sphere_3d.visible = true
			csg_sphere_3d_2.visible = true
			csg_sphere_3d.global_position = get_collision_point()
			var _pos := csg_sphere_3d.global_position
			csg_sphere_3d_2.global_position = Vector3(_pos.x - 0.5, _pos.y, _pos.z)
	else:
		if csg_sphere_3d:
			csg_sphere_3d.visible = false
		if csg_sphere_3d_2:
			csg_sphere_3d_2.visible = false
			
	if __log_dist: print_.prefix("Downcast dist", pp.s(global_position.distance_to(get_collision_point())))
