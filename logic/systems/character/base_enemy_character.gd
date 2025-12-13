#@tool
#@icon("res://-assets-/x_icons/red/icon_skull.png")

@abstract
class_name BaseEnemyCharacter
extends BaseCharacter

@export_group("Player")
@export var player: Princess

#
var camera_target: EnemyCameraTarget
@onready var coll_collider: CollisionShape3D = %CollCollider


func _initialise_cam_targets() -> void:
	var targets := get_descendants.enemy_camera_targets(self)
	for t: EnemyCameraTarget in targets:
		t.initialise(self)
		t.make_active()
	if len(targets) == 0:
		__log_error("len(targets) == 0", "", "camera_target = null")
		camera_target = null
		return

	if len(targets) > 1:
		__log_warn("len(targets) > 0; suport only one", "", "first will be used")

	camera_target = targets[0]


func _initialise_coll_collder():
	if coll_collider:
		var original_shape := coll_collider.shape
		if not error_.null_object(original_shape, "CollisionShape3D has no shape!"):
			if original_shape is not CapsuleShape3D:
				__log_warn("shape is not CapsuleShape3D. Not supported")
			else:
				# Duplicate to avoid shared resource issues
				coll_collider.shape = original_shape.duplicate()

	
func is_player() -> bool:
	return false