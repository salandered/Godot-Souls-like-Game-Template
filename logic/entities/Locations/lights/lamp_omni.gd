extends OmniLight3D

@onready var csg_sphere_3d: CSGSphere3D = $CSGSphere3D
@export var __dev_visual: bool =false

func _ready():
	if csg_sphere_3d:
		csg_sphere_3d.visible = __dev_visual
