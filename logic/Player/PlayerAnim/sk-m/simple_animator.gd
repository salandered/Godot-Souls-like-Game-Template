extends SkeletonModifier3D
class_name SimpleAnimator_

@export var native_animator: AnimationPlayer
@onready var skeleton = get_skeleton()

@export var a_name: String

var current_animation: Animation
# Animation also can be cyclical to linger infinitely, and each animation needs a variable to count progress for data interpolation. 
var current_animation_cycling: bool = true
var current_animation_progress: float = 0 # seconds

# if we are in the process of blending towards something, we have previous_animation defined
var previous_animation: Animation
var previous_animation_cycling: bool = true
var previous_animation_progress: float = 0 # seconds

# To blend between animations, we use a Boolean flag for execution routes. 
# And then the main variable here is `blending_percentage`.
#     - If zero, then we are full previous animation. If one, we play full current animation.
#     - We calculate `blending_percentage` by knowing the time over which we blend and counting the progress of the process.
var is_blending: bool = false
var blend_duration: float # seconds
var blend_time_spent: float # seconds
var blending_percentage: float # [0 ; 1]


# lazily use Unix time in milliseconds, just as in model states. 
# If you want to have a pause in your game or some time coefficients or to be immune to system time change attacks, create a better time calculation
var last_processing_time: float = 0 # seconds unix from system
var delta: float = 0 # seconds
var now: float = 0 # seconds unix from system

var bone_list: Array
var curr_transform: Transform3D
var previous_transform: Transform3D

var bone_position_track: int
var bone_rotation_track: int

var __initialised: bool = false

# func _ready():
# 	# TODO: this is not triggered. Added accept_modifiers(). Check with Godot 4.5
	#       see also: https://github.com/godotengine/godot/issues/106463
# 	# When we prepare our node, we make sure both animation fields are filled with "do nothing" animation. 
# 	current_animation = native_animator.get_animation("idle_longsword")
# 	current_animation_cycling = current_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR
# 	current_animation_progress = 0
# 	previous_animation = native_animator.get_animation("idle_longsword")
# 	previous_animation_cycling = previous_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR
# 	previous_animation_progress = 0


func play(next_animation: String, over_time: float = 0):
	if over_time < 0:
		push_error("can't blend two animations over " + str(over_time))
	
	last_processing_time = Time.get_unix_time_from_system()
	previous_animation = current_animation
	previous_animation_cycling = current_animation_cycling
	previous_animation_progress = current_animation_progress

	var anim := native_animator.get_animation(next_animation)
	if anim == null:
		push_error("Animation not found: " + next_animation)
		return

	current_animation = anim
	current_animation_progress = 0
	current_animation_cycling = current_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR

	if over_time > 0:
		is_blending = true
		blend_duration = over_time
		blend_time_spent = 0
		blending_percentage = 0


func _process_modification():
	if __initialised:
		_update_time()
		_update_blend_values()
		_update_skeleton()


func _update_skeleton():
	# - It works because in GDScript, this parameter in `for` loop syntax can be many things
	# 	- we abuse this fact by making it a collection of integers if we have a white list export field defined
	# 	- or if not (we work on the whole skeleton), we make this variable into a single integer value that represents all bones of the skeleton.
	if a_name == 'torso':
		bone_list = range(1, 44)
	elif a_name == 'legs':
		bone_list = range(45, 52)
		bone_list.append(0)
		bone_list.append(1) # ?
		# bone_list.append(2)
		# bone_list.append(3)

	elif a_name == 'full_body':
		bone_list = range(0, skeleton.get_bone_count())
	else:
		push_error("no a_name or its unknown")
	
	for bone in bone_list:
		# For each suggested bone, we first calculate its pose according to the `current_animation` and its progress.
		#   - If we don't blend, that's our work for the bone.
		#   - If we do blend, we need to also calculate this bone's pose according to the `previous_animation` and its progress, and then interpolate those two transforms via `blending_progress` value.
		curr_transform = calculate_bone_pose(bone, current_animation, current_animation_progress)
		if is_blending:
			previous_transform = calculate_bone_pose(bone, previous_animation, previous_animation_progress)
			skeleton.set_bone_pose(bone, previous_transform.interpolate_with(curr_transform, blending_percentage))
		else:
			skeleton.set_bone_pose(bone, curr_transform)


func _update_time():
	# Each frame, first thing we do is we manage our time awareness. 
		# - We do it by calculating the delta between now and the last call.
		# - We then add this delta to our animation progresses, and if animations are cycling, we undergo a cycle switch.
	now = Time.get_unix_time_from_system()
	delta = now - last_processing_time
	last_processing_time = now
	current_animation_progress += delta
	previous_animation_progress += delta
	if current_animation_progress > current_animation.length and current_animation_cycling:
		current_animation_progress = fmod(current_animation_progress, current_animation.length)
	if previous_animation_progress > previous_animation.length and previous_animation_cycling:
		previous_animation_progress = fmod(previous_animation_progress, previous_animation.length)


func _update_blend_values():
# We use the delta time value we just got and add it to blending_time_counter, 
# and then we update blending_percentage value. 
	if is_blending:
		blend_time_spent += delta
		blending_percentage = blend_time_spent / blend_duration
		if blending_percentage >= 1:
			blending_percentage = 1
			blending_percentage = 0
			blend_time_spent = 0
			is_blending = false


func calculate_bone_pose(bone_idx: int, animation: Animation, anim_progress: float) -> Transform3D:
	# - We search for a position track by turning our bone index into track path.
	# 	  - If -1, it means that `AnimationResource` doesn't contain such a track. For example, that bone doesn't move in this animation. 
	# 	In this case, we set transform's `origin` to the origin of our bone; we don't touch it.
	# 	  - If we find the track, we interpolate the value from it using progress.
	# - then we do the same with rotation. The only difference is type casting because animation stores rotation data in quaternions, but `Transform3D` stores it in basis vector triples.
	var resulting_transform: Transform3D
	
	bone_position_track = animation.find_track(bone_to_track_name(bone_idx), Animation.TYPE_POSITION_3D)
	if bone_position_track != -1:
		resulting_transform.origin = animation.position_track_interpolate(bone_position_track, anim_progress)
	else:
		resulting_transform.origin = skeleton.get_bone_pose(bone_idx).origin
	
	bone_rotation_track = animation.find_track(bone_to_track_name(bone_idx), Animation.TYPE_ROTATION_3D)
	if bone_rotation_track != -1:
		resulting_transform.basis = Basis(animation.rotation_track_interpolate(bone_rotation_track, anim_progress))
	else:
		resulting_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return resulting_transform


func bone_to_track_name(bone_index: int) -> String:
	return "%GeneralSkeleton:" + skeleton.get_bone_name(bone_index)
