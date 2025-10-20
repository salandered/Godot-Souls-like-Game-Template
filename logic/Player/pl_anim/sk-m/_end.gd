extends SkeletonModifier3D
class_name EndModifier

@onready var full_body: ModifierAnimator = %FullBody
@onready var legs: ModifierAnimator = %Legs
@onready var animation_settings: AnimationPlayer = %AnimationSettings

#@onready var debug_label := $"animation debug label"

@export var provides_root_velocity: bool

var __initialised: bool = false

var last_pose: Vector3
var cache: Dictionary

func initialise():
	__initialised = true

func bake_pose():
	for bone in get_skeleton().get_bone_count():
		cache[bone] = get_skeleton().get_bone_pose(bone)

func _process_modification():
	if __initialised and get_skeleton():
		bake_pose()
