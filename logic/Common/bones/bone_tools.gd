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


static func calculate_bone_pose_for_anim_playback(
		bone_idx: int,
		playback: AnimPlayback,
		skeleton: Skeleton3D,
		bone_idx_to_track: Dictionary
	) -> Transform3D:
	# Find pos/rot tracks using the bone's path.
	# If a track isn't found (-1), use the bone's current pose component (origin/basis).
	# If found, interpolate its value using the effective animation time.
	var result_transform: Transform3D
	
	# pre-cached track path
	var track_path: String = bone_idx_to_track.get(bone_idx, "")
	if track_path.is_empty():
		# This bone isn't in the _bone_idx_to_track map,
		# or the anim doesn't track it. Return current pose.
		return skeleton.get_bone_pose(bone_idx)
		
	var bone_pos_track := playback.anim.get_pos_track_idx(track_path)
	var bone_rot_track := playback.anim.get_rot_track_idx(track_path)
	
	# includes start_time_offset
	var playback_eff_time := playback.get_effective_time_spent()

	if bone_pos_track != -1:
		result_transform.origin = playback.anim.native_anim.position_track_interpolate(bone_pos_track, playback_eff_time)
	else: # keep curr pos
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin

	if bone_rot_track != -1:
		result_transform.basis = Basis(playback.anim.native_anim.rotation_track_interpolate(bone_rot_track, playback_eff_time))
	else:
		# keep curr rot
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform