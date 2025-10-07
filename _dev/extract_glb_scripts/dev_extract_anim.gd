@tool
extends EditorScript

## PRE RUN
## WARNING: Retarget skeleton IN GLB and hit REIMPORT !
## And check all configs below.

## RUN 
## ctrl shift X in Godot Script Editor

## POST RUN
## Load Libs to AnimationPlayer and StatesDatabase player.
## Check tracks are active.
## NOTE: Edit tracks for animations u plan to use.
##          - weapon hurts gap for attacking
##          - root_motion bool for attacking
##          - etc

# -> CHANGE THIS (without .glb)
#    NOTE: Library will be called using this name. Consider renaming .glb to something shorter. 
const SOURCE_GLB_NAME := "axe-rm-jumps" # "s-s" "test-export-1"

# -> CHANGE THIS: will be removed from animation names
const PREFIX_TO_REMOVE := "" # "sword and shield"


# -> CHECK THIS (usually we need param))
const PARAM := true

# -> CHECK THIS (could be changed later)
const LOOP_KEYWORDS := ["idle", "run", "sprint", "jog", "walk", "strafe", "loop", "cycle", "midair"]
const NOT_LOOP_KEYWORDS := ["jump", "land", "start", "end", "turn", "180", "90", "roll"] # priority over LOOP_KEYWORDS
# ---

# "res://-assets-/animations/GLB-packed/"
const SOURCE_GLB_PATH := "res://-assets-/animations/GLB-packed/axe/" # basic_packs
#const SOURCE_GLB_PATH := "res://-assets-/animations/GLB-packed/from_IR/" 
const TARGET_ROOT_FOLDER := "res://-assets-/animations/standard-skeleton/"
const ANIMATION_PLAYER_PATH := "AnimationPlayer"
var glb_path: String = SOURCE_GLB_PATH + SOURCE_GLB_NAME + ".glb"
var target_dir := TARGET_ROOT_FOLDER.path_join(SOURCE_GLB_NAME)
var target_param_dir := target_dir.path_join("param")

# # -> CHECK THIS (can be changed later)
# const PARAM_ANIM_PROPERTIES := [
# 	{"name": StatesDatabase.TRANSITIONS_TO_QUEUED, "type": TYPE_BOOL, "value": false},
# 	{"name": StatesDatabase.ACCEPTS_QUEUEING, "type": TYPE_BOOL, "value": false},
# 	{"name": StatesDatabase.IS_PARRYABLE, "type": TYPE_BOOL, "value": false},
# 	{"name": StatesDatabase.IS_VULNERABLE, "type": TYPE_BOOL, "value": true},
# 	{"name": StatesDatabase.IS_INTERRUPTABLE, "type": TYPE_BOOL, "value": true},
# 	{"name": StatesDatabase.WEAPON_HURTS, "type": TYPE_BOOL, "value": false},
# 	{"name": StatesDatabase.TRACKS_INPUT_VECTOR, "type": TYPE_BOOL, "value": true},
# 	{"name": StatesDatabase.ROOT_MOTION, "type": TYPE_BOOL, "value": false},
# ]

# # --- Script global vars ---
# var instance: Node
# var anim_player: AnimationPlayer


# func _run():
# 	print("\n--- Running Animation Extractor Script ---")
# 	if process_glb_file():
# 		print("--- ✔ finished successfully ---")
# 	else:
# 		print("--- ✖ finished with errors ---")


# func _extract_glb_data() -> bool:
# 	print("Processing file: ", glb_path)
	
# 	var packed_scene: PackedScene = ResourceLoader.load(glb_path)
# 	if not packed_scene:
# 		push_warning("Could not load scene resource: " + glb_path)
# 		return false

# 	instance = packed_scene.instantiate()
# 	if not instance:
# 		push_error("Failed to instantiate scene: " + glb_path)
# 		return false

# 	anim_player = instance.get_node_or_null(ANIMATION_PLAYER_PATH)
# 	if not anim_player:
# 		push_warning("No AnimationPlayer found at '%s' in: %s" % [ANIMATION_PLAYER_PATH, glb_path])
# 		return false
	
# 	return true

# func _create_target_directory() -> bool:
# 	var err_dir: int
# 	if PARAM:
# 		err_dir = DirAccess.make_dir_recursive_absolute(target_param_dir)
# 		if err_dir != OK:
# 			push_error("Failed to create directory: %s (Error code: %d)" % [target_param_dir, err_dir])
# 			_cleanup()
# 			return false
# 	else: # if/else here because target_param_dir contains target_dir in my case
# 		err_dir = DirAccess.make_dir_recursive_absolute(target_dir)
# 		if err_dir != OK:
# 			push_error("Failed to create directory: %s (Error code: %d)" % [target_dir, err_dir])
# 			_cleanup()
# 			return false

# 	print(" > Target directory for animations: ", target_dir)
# 	if PARAM: print(" > Target directory for param animations: ", target_param_dir)
# 	return true

# func _save_anim(anim: Animation, save_path: String):
# 	var err_save := ResourceSaver.save(anim, save_path)
# 	if err_save != OK:
# 		push_warning("Failed to save animation '" + anim.resource_name + "': " + save_path + " (Error code: %d)" % err_save)


# func process_glb_file() -> bool:
# 	if not _extract_glb_data():
# 		_cleanup()
# 		return false

# 	if not _create_target_directory():
# 		_cleanup()
# 		return false

# 	var animation_list := anim_player.get_animation_list()
# 	print(" > Found %d animations to extract: %s" % [animation_list.size(), animation_list])

# 	var anim_library := AnimationLibrary.new()
# 	var param_anim_library := AnimationLibrary.new()

# 	# save each animation as a .res and add to lib
# 	# if PARAM: save each param animation as a .res and add to param lib
# 	for anim_name in animation_list:
# 		var anim: Animation = anim_player.get_animation(anim_name)
# 		var copied_anim := anim.duplicate()
# 		var unified_name := _unify_name(anim_name)
		
# 		if _is_looped_animation(anim_name):
# 			copied_anim.loop_mode = Animation.LOOP_LINEAR

# 		anim_library.add_animation(unified_name, copied_anim)
# 		print("     > Added '%s' to AnimationLibrary." % unified_name)
		
# 		var save_name := unified_name + ".res"
# 		var save_path := target_dir.path_join(save_name)
# 		print("     > Saving '%s' to '%s'" % [unified_name, save_path])

# 		_save_anim(copied_anim, save_path)

# 		if PARAM:
# 			var unified_param_name := A.to_backend_anim(unified_name)
# 			var param_anim: Animation = _create_param_animation(copied_anim, unified_param_name)
			
# 			param_anim_library.add_animation(unified_param_name, param_anim)
# 			print("     > [PARAM] Added '%s' to AnimationLibrary." % unified_param_name)

# 			var save_param_name := unified_param_name + ".res"
# 			var save_param_path := target_param_dir.path_join(save_param_name)
# 			print("     > [PARAM] Saving '%s' to '%s'" % [unified_param_name, save_param_path])

# 			_save_anim(param_anim, save_param_path)

# 	_save_anim_lib(anim_library, target_dir.path_join(SOURCE_GLB_NAME + "-LIB.tres"))
# 	if PARAM: _save_anim_lib(param_anim_library, target_param_dir.path_join(SOURCE_GLB_NAME + "-LIB.tres")) # "-LIB-PARAM.tres"))

# 	_cleanup()
# 	return true


# func _create_param_animation(base_animation: Animation, unified_param_name: String) -> Animation:
# 	var param_anim := Animation.new()
# 	param_anim.length = base_animation.length
# 	param_anim.loop_mode = Animation.LOOP_NONE # no loop for -param
# 	param_anim.resource_name = unified_param_name

# 	var states_db_path_str := StatesDatabase.STATES_DB

# 	for prop in PARAM_ANIM_PROPERTIES:
# 		var name: String = prop["name"]
# 		# TODO: 'type' is for the future, right now all are bools. See helper function in the end as well.
# 		# var ptype: Variant.Type = prop["type"]
# 		var pvalue = prop["value"] # bool or Vector3

# 		var track_index := param_anim.add_track(Animation.TYPE_VALUE)
# 		var prop_path := NodePath("%s:%s"% [states_db_path_str, name])

# 		param_anim.track_set_path(track_index, prop_path)

# 		# Use discrete updates for bool/int to avoid interpolation artifacts
# 		param_anim.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)

# 		# insert keys 
# 		param_anim.track_insert_key(track_index, 0.0, pvalue)

# 		# Optional: duplicate last key at end for loop stability
# 		# if param_anim.loop_mode != Animation.LOOP_NONE:
# 		# 	param_anim.track_insert_key(track_index, param_anim.length, pvalue)

# 	return param_anim


# func _is_looped_animation(anim_name: String) -> bool:
# 	var anim_name_ := anim_name.to_lower()
# 	for block_word in NOT_LOOP_KEYWORDS:
# 		if anim_name_.find(block_word) != -1:
# 			return false
# 	for loop_word in LOOP_KEYWORDS:
# 		if anim_name_.find(loop_word) != -1:
# 			print("     > Animation '%s' set to looped." % anim_name)
# 			return true
# 	return false


# func _save_anim_lib(anim_library: AnimationLibrary, lib_save_path: String) -> void:
# 	var err_save_library := ResourceSaver.save(anim_library, lib_save_path)
# 	if err_save_library != OK:
# 		push_warning("Failed to save AnimationLibrary: " + lib_save_path + " (Error code: %d)" % err_save_library)
# 	else:
# 		print(" > Saved AnimationLibrary to: ", lib_save_path)


# func _unify_name(name: String) -> String:
# 	var unified_name := name
# 	if PREFIX_TO_REMOVE != "":
# 		unified_name = unified_name.trim_prefix(PREFIX_TO_REMOVE)
		
# 	unified_name = unified_name.strip_edges()
	
# 	return unified_name.replace(" ", "-").replace("_", "-").replace("(", "").replace(")", "")


# func _cleanup():
# 	if instance: instance.queue_free()


# ## helper: pick sensible update mode for value tracks
# # static func __update_mode_for_type(t: int) -> int:
# 	# match t:
# 	# 	TYPE_BOOL, TYPE_INT:
# 	# 		return Animation.UPDATE_DISCRETE
# 	# 	_:
# 	# 		return Animation.UPDATE_CONTINUOUS
