extends SkeletonModifier3D
class_name BeginModifier

@onready var animation_player: AnimationPlayer = %NativeAnimator
@onready var end_modifier: EndModifier = %_End

var __initialised: bool = false

func initialise():
	__initialised = true

# because we manage our modifiers via influence manipulations, we often have active ones with 0 influence
# to not waste our computation power on them, the first "meta modifier" deactivates 0-influenced ones
# and activates non-zero modifiers.
# This works because if this modifier is the first before all, it triggers first, 
# but also triggers after "purple" nodes, ie after we set all influences for the frame.
func _process_modification():
	# TODO: problem with get_skeleton() on the start. Work in 4.3 but not 4.4. Check with Godot 4.5
	if __initialised and get_skeleton():
		restore_pose()
		for child in get_skeleton().get_children():
			if child is SkeletonModifier3D:
				if child.influence == 0:
					child.active = false
				else:
					child.active = true

func restore_pose():
	var cache: Dictionary = end_modifier.cache
	if not cache.is_empty():
		for bone in get_skeleton().get_bone_count():
			get_skeleton().set_bone_pose(bone, cache[bone])
