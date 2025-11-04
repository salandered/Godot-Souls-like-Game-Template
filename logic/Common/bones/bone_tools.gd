extends RefCounted
class_name BoneTools


## soft 
static func validate_skeleton(skeleton: Skeleton3D) -> bool: # {int: String}
	var bone_count = skeleton.get_bone_count()
	if bone_count != Constants.BONE_COUNT:
		# soft warn
		print_.warn(false, "bone_count != Constants.BONE_COUNT", "PlayerModifierAnimator", pp.s("we always use", Constants.BONE_COUNT, ", regardless."), bone_count)
		return false
	return true


static func calculate_bone_idx_to_track(skeleton: Skeleton3D) -> Dictionary: # {int: String}
	var result = {}

	var full_body := BoneMask.get_full_body_with_root()

	for bone_idx in full_body:
		result[bone_idx] = Constants.BONE_TRACK_PREFIX + skeleton.get_bone_name(bone_idx)

	return result