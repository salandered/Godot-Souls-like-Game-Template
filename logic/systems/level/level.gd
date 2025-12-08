extends Node3D

## TODO: tie with BaseLevel

@onready var player_pack: Princess = $PrincessPack
@onready var lighting: Node3D = $LIGHTING
@onready var world_environment: WorldEnvironment = $LIGHTING/WorldEnvironment

# var entrypoint: Entrypoint
# recursively sets collision layer and mask for all CSG nodes in the tree
func _set_collision_recursive(node: Node3D):
	if node is CSGBox3D or node is CSGTorus3D or node is CSGCylinder3D:
		node.collision_layer = Collision.Layers.ENVIRONMENT_COL
		node.collision_mask = Collision.Masks.ENVIRONMENT_COL_MASK
		print_.collisions(node)
	# do not traverse children if node is Character3D
	if node is CharacterBody3D:
		return
	for child in node.get_children():
		_set_collision_recursive(child)

func _ready() -> void:
	_set_collision_recursive(self)


func make_camera_current():
	player_pack.fancy_camera.camera.make_current()
