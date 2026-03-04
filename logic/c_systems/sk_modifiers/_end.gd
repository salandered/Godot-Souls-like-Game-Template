extends SkeletonModifier3D
class_name EndModifier

@onready var full_body: PlayerModifierAnimator = %FullBody

var __initialized: bool = false

var last_pose: Vector3
var cache: Dictionary[int, Transform3D]

func initialize() -> void:
	__initialized = true

func bake_pose():
	for bone_idx in get_skeleton().get_bone_count():
		cache[bone_idx] = get_skeleton().get_bone_pose(bone_idx)

func _process_modification():
	if __initialized and get_skeleton():
		bake_pose()
