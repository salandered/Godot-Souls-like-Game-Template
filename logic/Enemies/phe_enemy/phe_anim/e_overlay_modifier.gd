extends SkeletonModifier3D
class_name OverlayModifier

@onready var skeleton := get_skeleton()
@onready var anim_container: AnimationContainer = %AnimContainer


var overlay_playback: AnimPlayback
var overlay_timing: OverlayTiming
var overlay_is_active := false
var overlay_weight := 0.0

var bone_mask: Array[int]

var default_bones: Array[int]
var overlay_speed: float = 1.0

var last_time: float = 0.0
var custom_delta: float = 0.0
var _bone_idx_to_track: Dictionary = {}


var __initialised: bool = false


func initialise():
	BoneTools.validate_skeleton(skeleton)
	
	default_bones = BoneMask.get_full_body_no_root()
	
	# Cache bone track paths
	_bone_idx_to_track = BoneTools.calculate_bone_idx_to_track(skeleton)

	__initialised = true


func set_overlay_anim(anim: AnimationData, overlay_config: OverlayConfig):
	overlay_playback = AnimPlayback.new(anim, 0.0, 0.0)

	var anim_duration := anim.duration
	if anim.does_marker_exist(Marker.Name_.OVERLAY_START) and anim.does_marker_exist(Marker.Name_.OVERLAY_END):
		var start_t := anim.get_marker_time_by_name(Marker.Name_.OVERLAY_START)
		var end_t := anim.get_marker_time_by_name(Marker.Name_.OVERLAY_END)
		anim_duration = end_t - start_t
		__log_("used markers for overlay anim", pp.in_q(anim.anim_name), "start:", start_t, "end:", end_t, "orig dur/new:", anim.duration, anim_duration)
	
	overlay_timing = OverlayTiming.new(anim_duration, overlay_config)

	__log_(overlay_timing)

	overlay_is_active = true
	overlay_weight = 0.0
	overlay_speed = overlay_config.get_speed_scale()
	bone_mask = overlay_config.get_bone_mask()
	last_time = Time.get_unix_time_from_system()


func _process_modification():
	if not __initialised:
		return
	if not overlay_is_active:
		return

	__log_process_start()

	_update_time()
	_update_blend_values()
	_apply_overlay()


func _update_time():
	var now = Time.get_unix_time_from_system()
	custom_delta = now - last_time
	last_time = now
	
	overlay_playback.time_spent += custom_delta * overlay_speed


func _update_blend_values():
	var time_spent = overlay_playback.time_spent
	if time_spent < overlay_timing.get_total_duration():
		overlay_weight = overlay_timing.get_weight_at_time(time_spent)
	else:
		overlay_weight = 0.0
		overlay_is_active = false


func _apply_overlay():
	if overlay_weight <= 0:
		return
	
	var bones_to_modify: Array[int]
	if bone_mask.is_empty():
		__log_("bone_mask is empty, using default bone mask")
		bones_to_modify = default_bones
	else:
		bones_to_modify = bone_mask

	__log_applying(bones_to_modify)

	for bone_idx in bones_to_modify:
		var base_pose = skeleton.get_bone_pose(bone_idx)
		var overlay_pose = _calculate_overlay_bone_pose(bone_idx)

		var final_pose = Transform3D()
		if bone_idx == 1: # # Blend rotation only for Hips (1)
			final_pose.origin = base_pose.origin # keep base position
			final_pose.basis = base_pose.basis.slerp(overlay_pose.basis, overlay_weight)
		else:
			final_pose = base_pose.interpolate_with(overlay_pose, overlay_weight)
		
		skeleton.set_bone_pose(bone_idx, final_pose)
		__log_overlay_start(bone_idx, base_pose, overlay_pose, final_pose)

			
func _calculate_overlay_bone_pose(bone_idx: int) -> Transform3D:
	if not overlay_playback: # should not happen
		return skeleton.get_bone_pose(bone_idx)

	# Reference: Player's _calculate_bone_pose()
	var result_transform: Transform3D
	var track_path: String = _bone_idx_to_track[bone_idx]
	
	var bone_pos_track = overlay_playback.anim.get_pos_track_idx(track_path)
	var bone_rot_track = overlay_playback.anim.get_rot_track_idx(track_path)
	var playback_time = overlay_playback.time_spent
	
	if bone_pos_track != -1:
		result_transform.origin = overlay_playback.anim.native_anim.position_track_interpolate(bone_pos_track, playback_time)
	else:
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin
	
	if bone_rot_track != -1:
		result_transform.basis = Basis(overlay_playback.anim.native_anim.rotation_track_interpolate(bone_rot_track, playback_time))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform


func __log_(...parts: Array):
	print_.anim_manager("Enemy Overlay", pp.list_(parts))


var __LOG_OVERLAY_START_B: bool = false
var __LOG_PROCESS_START_B: bool = false


func __log_overlay_start(bone_idx, base_pose, overlay_pose, final_pose):
	if bone_idx < 3 and overlay_playback.time_spent < 0.1 and __LOG_OVERLAY_START_B:
		__log_("Bone", bone_idx, skeleton.get_bone_name(bone_idx))
		__log_("  Base pos:", base_pose.origin, "Overlay pos:", overlay_pose.origin)
		__log_("  Weight:", overlay_weight, "Final:", final_pose.origin)


func __log_applying(bones_to_modify):
	if u.ifr() % 60 == 0:
		__log_("Applying overlay. Weight:", overlay_weight, "Bones:", bones_to_modify.slice(0, 5), "...")


func __log_process_start(...parts: Array):
	if overlay_playback.time_spent < custom_delta * 2 and __LOG_PROCESS_START_B:
		__log_("=== OVERLAY STARTED ===")
		__log_("Anim:", overlay_playback.anim.anim_name)
		__log_("Duration:", overlay_timing.get_total_duration())
		__log_("Bone mask:", bone_mask)
		__log_("Skeleton bone count:", skeleton.get_bone_count())
