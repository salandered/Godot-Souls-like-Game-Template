extends SkeletonModifier3D

# Each frame we advance a sine wave, compute a weight, then rotate the current animated local bases of lower_leg/foot/hips by small angles,
# proportional to that weight—engine blends the result via modifier influence.
class_name LimpModifier

# # Bone to affect (set via dropdown populated by _validate_property)
# var shin_bone: String = "RightLowerLeg"
# var thigh_bone: String = "RightUpperLeg"
# # We are no longer modifying the foot bone to prevent conflicts with the base animation.
# var hip_bone: String = "Hips"
# var foot_bone: String = "RightFoot"


# ## MODIFIER DESCRIPTION:
# ## Applies a procedural limp by lowering the hips and using a two-bone IK solver 
# ## to plant the affected foot on the ground, preventing it from clipping.
# ## The limp intensity is synchronized with an AnimationPlayer's progress.


# # --- LIMP PARAMETERS ---
# var intensity: float = 1.0
# var hip_vertical_drop: float = 0.08 # Vertical drop in meters at limp peak.
# var foot_roll_deg: float = 5.0 # Optional foot roll.

# # --- SCRIPT VARS ---
# var _hip_idx: int = -1
# var _thigh_idx: int = -1
# var _shin_idx: int = -1
# var _foot_idx: int = -1

# var _phase: float = 0.0
# var _is_initialized: bool = false
# var skeleton: Skeleton3D

# # --- ANIMATION SOURCE ---
# # You need to link this to your animation source to sync the limp cycle.
# @onready var player_sm: PlayerSM = %PlayerSM


# func _setup_modifier():
# 	skeleton = get_skeleton()
# 	if not skeleton:
# 		printerr("LimpModifier: Skeleton3D not found!")
# 		return

# 	_hip_idx = skeleton.find_bone(hip_bone)
# 	_thigh_idx = skeleton.find_bone(thigh_bone)
# 	_shin_idx = skeleton.find_bone(shin_bone)
# 	_foot_idx = skeleton.find_bone(foot_bone)

# 	if -1 in [_hip_idx, _thigh_idx, _shin_idx, _foot_idx]:
# 		assert(false)
# 		_is_initialized = false
# 		return

# 	print("Limp Modifier Initialized.")
# 	_is_initialized = true


# func _process_modification():
# 	if not _is_initialized:
# 		if get_skeleton(): # Attempt to initialize if not already
# 			_setup_modifier()
# 		return
	
# 	# 1. Synchronize limp phase with animation progress
# 	_update_phase()

# 	# 2. Calculate the limp weight for this frame
# 	# Use a half-sine wave so the effect only occurs on one step of the cycle.
# 	var weight: float = max(0.0, sin(_phase)) * intensity
# 	if weight < 0.001:
# 		return # No limp effect on this frame, do nothing.

# 	# 3. Apply the IK-driven limp
# 	_apply_limp_ik(weight)


# func _update_phase():
# 	if not is_instance_valid(player_sm): return
# 	var anim_progress = animator_manager.curr_anim_progress
# 	var anim_length = animator_manager.curr_anim.duration

# 	if anim_length > 0:
# 		_phase = TAU * fposmod(anim_progress / anim_length, 1.0)


# func _apply_limp_ik(weight: float):
# 	# Get current global transforms of the leg bones
# 	var hip_global_pose := skeleton.get_bone_global_pose(_hip_idx)
# 	var thigh_global_pose := skeleton.get_bone_global_pose(_thigh_idx)
# 	var shin_global_pose := skeleton.get_bone_global_pose(_shin_idx)
# 	var foot_global_pose := skeleton.get_bone_global_pose(_foot_idx)

# 	# --- IK Calculation ---
# 	var thigh_len: float = thigh_global_pose.origin.distance_to(shin_global_pose.origin)
# 	var shin_len: float = shin_global_pose.origin.distance_to(foot_global_pose.origin)

# 	# Define the hip's new lowered position
# 	var hip_target_pos: Vector3 = hip_global_pose.origin + Vector3.DOWN * hip_vertical_drop * weight
	
# 	# Define the foot's target: stay on the ground (Y=0 in skeleton space)
# 	# We preserve its XZ position from the original animation.
# 	var foot_target_pos: Vector3 = foot_global_pose.origin
# 	foot_target_pos.y = 0.0

# 	# Vector from the new hip position to the foot target
# 	var hip_to_foot_vec: Vector3 = foot_target_pos - hip_target_pos
# 	var target_dist: float = hip_to_foot_vec.length()

# 	# Clamp distance to prevent leg from over-extending
# 	if target_dist > thigh_len + shin_len:
# 		target_dist = thigh_len + shin_len
# 		hip_to_foot_vec = hip_to_foot_vec.normalized() * target_dist

# 	# --- Use Law of Cosines to find knee and hip angles ---
# 	# Angle for the thigh
# 	var thigh_angle_rad: float = acos((thigh_len * thigh_len + target_dist * target_dist - shin_len * shin_len) / (2.0 * thigh_len * target_dist))
# 	# Angle for the shin (knee bend)
# 	var shin_angle_rad: float = acos((thigh_len * thigh_len + shin_len * shin_len - target_dist * target_dist) / (2.0 * thigh_len * shin_len))

# 	# --- Determine the axis of rotation (the knee's bending axis) ---
# 	# We use the cross product to find a vector perpendicular to the leg plane.
# 	# This ensures the knee bends naturally.
# 	var leg_plane_normal: Vector3 = (thigh_global_pose.origin - hip_global_pose.origin).cross(foot_global_pose.origin - hip_global_pose.origin).normalized()
# 	if leg_plane_normal.is_zero_approx(): # Handle case where leg is perfectly straight
# 		leg_plane_normal = hip_global_pose.basis.x

# 	# --- Apply the new bone poses ---
# 	# 1. Position the Hip
# 	var new_hip_pose = skeleton.get_bone_pose(_hip_idx)
# 	new_hip_pose.origin += new_hip_pose.basis.y * (-hip_vertical_drop * weight)
# 	skeleton.set_bone_pose(_hip_idx, new_hip_pose)
	
# 	# 2. Rotate the Thigh
# 	var new_thigh_pose = skeleton.get_bone_pose(_thigh_idx)
# 	var thigh_rotation = Transform3D.IDENTITY.rotated(hip_to_foot_vec.cross(leg_plane_normal).normalized(), hip_to_foot_vec.angle_to(Vector3.DOWN))
# 	thigh_rotation = thigh_rotation.rotated(leg_plane_normal, thigh_angle_rad)
	
# 	var parent_pose := skeleton.get_bone_global_pose(skeleton.get_bone_parent(_thigh_idx))
# 	new_thigh_pose = parent_pose.affine_inverse() * Transform3D(thigh_rotation.basis, thigh_global_pose.origin)
# 	skeleton.set_bone_pose(_thigh_idx, new_thigh_pose)
	
# 	# 3. Rotate the Shin (Knee Bend)
# 	var new_shin_pose = skeleton.get_bone_pose(_shin_idx)
# 	var shin_rotation = Basis().rotated(leg_plane_normal, PI - shin_angle_rad) # PI for convex knee bend
# 	new_shin_pose.basis = shin_rotation
# 	skeleton.set_bone_pose(_shin_idx, new_shin_pose)

# 	# 4. (Optional) Apply foot roll for added effect
# 	var new_foot_pose = skeleton.get_bone_pose(_foot_idx)
# 	var roll_axis = new_foot_pose.basis.z # Roll along the foot's forward axis
# 	new_foot_pose.basis = new_foot_pose.basis.rotated(roll_axis, deg_to_rad(foot_roll_deg) * weight)
# 	skeleton.set_bone_pose(_foot_idx, new_foot_pose)


# # Function to populate bone names in the editor inspector
# func _validate_property(p: Dictionary) -> void:
# 	if p.name in ["hip_bone", "thigh_bone", "shin_bone", "foot_bone"]:
# 		var skel = get_skeleton()
# 		if skel:
# 			p.hint = PROPERTY_HINT_ENUM
# 			p.hint_string = skel.get_concatenated_bone_names()
