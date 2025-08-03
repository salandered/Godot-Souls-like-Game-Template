@tool
extends EditorScript


## Written for one-time usage to save time. 
# - Runs the exact same process of splitting an animation in two, but it processes not one animation, but all animations in a chosen library.
# - Here was an `AnimationPlayer` with all our animations. I just saved the global section as a library, and here you go: two new libraries ready to be imported as a whole to these animators.
# - The code is almost the same. The only difference is we don't have a skeleton (as we don’t have a scene), so I use the player's model scene as a sort of skeleton reference for our indexes research.


# skeleton reference
const SKELETON_NAME = "GeneralSkeleton"
const _SCENE_FOLDER := "res://"
const SCENE_PATH := _SCENE_FOLDER + "playerModel-back.tscn"

# anim lib
var LIB := true
const _ANIMATION_FOLDER := "res://souls-tut/Assets/Ready Animations/"
const LIBRARY_FOLDER := _ANIMATION_FOLDER + "libs/"
const SOURCE_LIB = "ss_strafe.res"
const SOURCE_LIBRARY_PATH = LIBRARY_FOLDER + SOURCE_LIB

# single anim
var ANIM_NAME := "strafe-R_X"
var source_animation_path := _ANIMATION_FOLDER + "_forged/"  + ANIM_NAME + ".res"
var output_folder :=  _ANIMATION_FOLDER + "_forged/"

var library = preload(SOURCE_LIBRARY_PATH) as AnimationLibrary
var skeleton_reference_scene = preload(SCENE_PATH)


func _run():
	if not library:
		print("no library")
		return 
	if not skeleton_reference_scene:
		print("no skeleton_reference_scene")
		return 
	var scene := skeleton_reference_scene.instantiate()
	if not scene:
		print("no scene")
		return
	var skeleton = scene.get_node(SKELETON_NAME) as Skeleton3D
	if not skeleton:
		print("no skeleton")
		if scene: scene.queue_free()
		return
	
	if not LIB:
		var animation = ResourceLoader.load(source_animation_path) as Animation
		if not animation: 
			print("no animation")
			if scene: scene.queue_free()
			return
		var torso_and_legs := split_animation(skeleton, animation)
		var original_file_name = source_animation_path.get_file().get_basename()
		var torso_path = output_folder + original_file_name + "_torso.res"
		var legs_path = output_folder + original_file_name + "_legs.res"
		ResourceSaver.save(torso_and_legs[0], torso_path)
		ResourceSaver.save(torso_and_legs[1], legs_path)
		print("Animation split and saved to:")
		print("  - Torso: " + torso_path)
		print("  - Legs: " + legs_path)
	
	else: 
		var new_legs_library: AnimationLibrary = AnimationLibrary.new()
		var new_torso_library: AnimationLibrary = AnimationLibrary.new()
		for animation_name in library.get_animation_list():
			var animation := library.get_animation(animation_name) as Animation
			print("processing animation ", animation_name)
			if not animation:
				print("no animation ", animation_name)
				return
			var torso_and_legs := split_animation(skeleton, animation) # 0: torso, 1: legs
			new_torso_library.add_animation(animation_name + "_torso", torso_and_legs[0])
			new_legs_library.add_animation(animation_name + "_legs", torso_and_legs[1])
		print(new_legs_library.get_animation_list())
		print(new_torso_library.get_animation_list())
		
		var torso_save_path =  LIBRARY_FOLDER + "torso/" + SOURCE_LIB
		print("gonna save to ", torso_save_path)
		var legs_save_path =  LIBRARY_FOLDER + "legs/" + SOURCE_LIB
		print("gonna save to ", legs_save_path)
		ResourceSaver.save(new_torso_library, torso_save_path)
		ResourceSaver.save(new_legs_library, legs_save_path)
	
	if scene: scene.queue_free()

func split_animation(skeleton: Skeleton3D, animation: Animation) -> Array[Animation]:
	var new_torso_animation: Animation = Animation.new()
	var new_legs_animation: Animation = Animation.new()
	new_torso_animation.length = animation.length
	new_legs_animation.length = animation.length
	var torso_indeces := _get_torso_bones_indeces(skeleton)
	var legs_indeces := _get_legs_bones_indeces(skeleton)
	for track in animation.get_track_count():
		var track_path: String = animation.track_get_path(track)
		var bone_name := track_path.replace("%" + SKELETON_NAME + ":", "")
		var bone_index := skeleton.find_bone(bone_name)
		if torso_indeces.has(bone_index):
			animation.copy_track(track, new_torso_animation)
		if legs_indeces.has(bone_index):
			animation.copy_track(track, new_legs_animation)
	return [new_torso_animation, new_legs_animation]

func _get_torso_bones_indeces(skeleton: Skeleton3D) -> Array:
	return _get_hierarchy_indexes(skeleton, 1)


func _get_legs_bones_indeces(skeleton: Skeleton3D) -> Array:
	var right_leg_indeces := _get_hierarchy_indexes(skeleton, skeleton.find_bone("RightUpperLeg"))
	var left_leg_indeces := _get_hierarchy_indexes(skeleton, skeleton.find_bone("LeftUpperLeg"))
	var result := [0] # Hips
	result.append_array(right_leg_indeces)
	result.append_array(left_leg_indeces)
	return result


func _get_hierarchy_indexes(skeleton: Skeleton3D, root_idx: int) -> Array:
	var indeces = []
	for child_bone in skeleton.get_bone_children(root_idx):
		indeces.append_array(_get_hierarchy_indexes(skeleton, child_bone))
	indeces.append(root_idx)
	indeces.sort()
	return indeces


#@tool
#extends EditorScript
#
#@export_group("Configuration")
#@export var source_animation_path: String = "res://souls-tut/Assets/Ready Animations/ss/strafe-R.tres"
#@export var output_folder: String = "res://souls-tut/Assets/Ready Animations/split_results/"
#@export var skeleton_name: String = "GeneralSkeleton"
#@export var skeleton_reference_scene_path: String = "res://dev_skeleton_animator.tscn"
#
#func split_animation(skeleton: Skeleton3D, animation: Animation) -> Array[Animation]:
	#return [animation.duplicate(), animation.duplicate()]
#
#func _run() -> void:
	#var animation = ResourceLoader.load(source_animation_path) as Animation
	#var scene_res = ResourceLoader.load(skeleton_reference_scene_path) as PackedScene
	#var scene := scene_res.instantiate()
	#var skeleton = scene.get_node(skeleton_name) as Skeleton3D
	#var torso_and_legs := split_animation(skeleton, animation)
	#var original_file_name = source_animation_path.get_file().get_basename()
	#var torso_path = output_folder + original_file_name + "_torso.res"
	#var legs_path = output_folder + original_file_name + "_legs.res"
	#ResourceSaver.save(torso_and_legs[0], torso_path)
	#ResourceSaver.save(torso_and_legs[1], legs_path)
	#print("Animation split and saved to:")
	#print("  - Torso: " + torso_path)
	#print("  - Legs: " + legs_path)
	#scene.queue_free()
