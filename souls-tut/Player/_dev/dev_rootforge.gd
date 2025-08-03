@tool
extends EditorScript

enum Axes {
	X,
	Y,
	Z,
}

# -> SET TO AXES AND VALUE (would be nailed to this value)
# var nail_axis: Axes = Axes.Z
# var nail_value: float = -0.062

var nail_axis: Axes = Axes.X
var nail_value: float = 0.0

# -> CHECK ANIM NAMES (without lib prefix) and LIB PREFIX
var result_anim_name := "strafe-R"
var result_backend_anim_name := "strafe-R_params"
var lib := "ss/"

# -> FOLDER TO SAVE RESULTS (relative to ANIMATION_FOLDER)
const RESULT_FOLDER = "_forged/"

# -> DO U NEED BACKEND PARAM MODIFIED?
var MODIFY_BACKEND := false


# -> RESAVE THIS TWO NODES AS SCENES AT THE ROOT
const scenes_path := "res://"
const dev_sk_animator_scene_path := scenes_path + "dev_skeleton_animator.tscn"
const states_db_scene_path := scenes_path + "states_database.tscn"

# USUALLY SHOULD NOT BE CHANGED
var anim_name := lib + result_anim_name
var backend_anim_name := lib + result_backend_anim_name
const SKELETON_NAME := "GeneralSkeleton"
const ANIMATION_FOLDER = "res://souls-tut/Assets/Ready Animations/"

var CREATE_BACKUPS := true
var BACKUP_FOLDER = ANIMATION_FOLDER + "_backups/"
var backup_path = BACKUP_FOLDER + result_anim_name + "_08.res"
var backup_backend_path = BACKUP_FOLDER + result_backend_anim_name + "_08.res"

var dev_sk_animator_scene = preload(dev_sk_animator_scene_path)
var states_db_scene = preload(states_db_scene_path)

# --- CLASS-LEVEL VARIABLES ---
var dev_sk_animator: Node
var states_db: Node
var animation: Animation
var backend_animation: Animation
var hips_track: int = -1
var backend_track: int = -1

func _run() -> void:
	hips_track = _prepare_hips_track()
	if hips_track == -1:
		return

	if MODIFY_BACKEND:
		backend_track = _prepare_backend_track()
		if backend_track == -1:
			MODIFY_BACKEND = false

	if CREATE_BACKUPS:
		_create_backups()

	print("Processing animation...")
	print(animation.track_get_key_count(hips_track))
	
	for i: int in animation.track_get_key_count(hips_track):
		var position = animation.track_get_key_value(hips_track, i)
		var time = animation.track_get_key_time(hips_track, i)
		
		if MODIFY_BACKEND:
			backend_animation.track_insert_key(backend_track, time, position)
		print(str(position) + " at " + str(time))
		
		var position_modified = position
		match nail_axis:
			Axes.X:
				position_modified.x = nail_value
			Axes.Y:
				position_modified.y = nail_value
			Axes.Z:
				position_modified.z = nail_value
		
		animation.track_set_key_value(hips_track, i, position_modified)
	
	var suffix := _choose_result_anim_suffix()
	var anim_path := ANIMATION_FOLDER + RESULT_FOLDER + result_anim_name + suffix
	print("gonna save anim to ", anim_path)
	ResourceSaver.save(animation, anim_path)
	
	if MODIFY_BACKEND:
		var backend_suffix := _choose_result_backend_anim_suffix()
		var backend_anim_path := ANIMATION_FOLDER + RESULT_FOLDER + result_backend_anim_name + backend_suffix
		print("gonna save backend anim to ", backend_anim_path)
		ResourceSaver.save(backend_animation, backend_anim_path)

	if dev_sk_animator: dev_sk_animator.queue_free()
	if states_db: states_db.queue_free()

	print("Animation processed and saved successfully.")


func _prepare_hips_track() -> int:
	dev_sk_animator = dev_sk_animator_scene.instantiate()
	if not dev_sk_animator:
		push_error("Could not instantiate scenes")
		return -1
	animation = dev_sk_animator.get_animation(anim_name) as Animation
	if not animation:
		push_error("Animations not found.")
		dev_sk_animator.queue_free()
		return -1
	hips_track = animation.find_track("%" + SKELETON_NAME + ":Hips", Animation.TYPE_POSITION_3D)
	if hips_track == -1:
		push_error("Could not find required tracks. Aborting.")
		dev_sk_animator.queue_free()
		return -1
	return hips_track

func _prepare_backend_track() -> int:
	states_db = states_db_scene.instantiate()
	if not states_db:
		push_error("Could not instantiate states_db scenes")
		return -1
	backend_animation = states_db.get_animation(backend_anim_name) as Animation
	if not backend_animation:
		push_error("Animations backend_animation not found")
		states_db.queue_free()
		return -1
	backend_track = backend_animation.find_track("StatesDatabase:root_position", Animation.TYPE_VALUE)
	if backend_track == -1:
		push_error("Could not find required backend_track")
		states_db.queue_free()
		return -1
	return backend_track

func _choose_result_anim_suffix() -> String:
	var result := ""
	match nail_axis:
		Axes.X:
			result = "_X.res"
		Axes.Y:
			result = "_Y.res"
		Axes.Z:
			result = "_Z.res"
	return result

func _choose_result_backend_anim_suffix() -> String:
	var result := ""
	match nail_axis:
		Axes.X:
			result = "_WITH_ROOT_X.res"
		Axes.Y:
			result = "_WITH_ROOT_Y.res"
		Axes.Z:
			result = "_WITH_ROOT_Z.res"
	return result


func _create_backups():
	ResourceSaver.save(animation, backup_path)
	if MODIFY_BACKEND:
		ResourceSaver.save(animation, backup_backend_path)
