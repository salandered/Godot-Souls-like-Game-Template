@tool
extends EditorScript

const SOURCE_GLB_PATH := "res://-assets-/animations/GLB-packed/"

# -> CHANGE IT (without .glb)
const SOURCE_GLB_NAME := "s-s"

# -> CHANGE IT: will be removed from animation names
const PREFIX_TO_REMOVE := "sword and shield"
# ---

const TARGET_ROOT_FOLDER := "res://-assets-/animations/standard-skeleton/"
const ANIMATION_PLAYER_PATH := "AnimationPlayer"
var glb_path: String = SOURCE_GLB_PATH + SOURCE_GLB_NAME + ".glb"
var target_dir := TARGET_ROOT_FOLDER.path_join(SOURCE_GLB_NAME)

# --- Script global vars ---
var instance: Node
var anim_player: AnimationPlayer


func _run():
	print("--- Running Animation Extractor Script ---")
	if process_glb_file():
		print("--- ✔ finished successfully ---")
	else:
		print("--- ✖ finished with errors ---")


func _extract_glb_data() -> bool:
	print("Processing file: ", glb_path)
	
	var packed_scene: PackedScene = ResourceLoader.load(glb_path)
	if not packed_scene:
		push_warning("Could not load scene resource: " + glb_path)
		return false

	instance = packed_scene.instantiate()
	if not instance:
		push_error("Failed to instantiate scene: " + glb_path)
		return false

	anim_player = instance.get_node_or_null(ANIMATION_PLAYER_PATH)
	if not anim_player:
		push_warning("No AnimationPlayer found at '%s' in: %s" % [ANIMATION_PLAYER_PATH, glb_path])
		_cleanup()
		return false
	
	return true


func process_glb_file() -> bool:
	if not _extract_glb_data():
		return false

	# Create the target directory if it doesn't exist.
	print(" > Target directory for animations: ", target_dir)
	var err_dir = DirAccess.make_dir_recursive_absolute(target_dir)
	if err_dir != OK:
		push_error("Failed to create directory: %s (Error code: %d)" % [target_dir, err_dir])
		_cleanup()
		return false

	var animation_list := anim_player.get_animation_list()
	print(" > Found %d animations to extract: %s" % [animation_list.size(), animation_list])

	var anim_library := AnimationLibrary.new()

	# Loop through each animation and save it as a separate .res file.
	for anim_name in animation_list:
		var anim: Animation = anim_player.get_animation(anim_name)
		var copied_anim := anim.duplicate()
		var unified_name := _unify_name(anim_name)
		
		# Add the animation to the library using unified name
		anim_library.add_animation(unified_name, copied_anim)
		print("     > Added '%s' to AnimationLibrary." % unified_name)
		# ---
		
		var save_name := unified_name + ".res"
		var save_path := target_dir.path_join(save_name)
		print("     > Saving '%s' to '%s'" % [anim_name, save_path])
		
		var err_save := ResourceSaver.save(copied_anim, save_path)
		if err_save != OK:
			push_warning("Failed to save animation: " + save_path + " (Error code: %d)" % err_save)

	_save_anim_lib(anim_library)

	_cleanup()
	return true


func _save_anim_lib(anim_library: AnimationLibrary):
	var anim_file_name := "_" + SOURCE_GLB_NAME + "_LIB" + ".tres"
	var library_path := target_dir.path_join(anim_file_name)
	var err_save_library := ResourceSaver.save(anim_library, library_path)
	if err_save_library != OK:
		push_warning("Failed to save AnimationLibrary: " + library_path + " (Error code: %d)" % err_save_library)
	else:
		print(" > Saved AnimationLibrary to: ", library_path)


func _unify_name(name: String) -> String:
	var unified_name := name
	if PREFIX_TO_REMOVE != "":
		unified_name = unified_name.trim_prefix(PREFIX_TO_REMOVE)
		
	unified_name = unified_name.strip_edges()
	
	return unified_name.replace(" ", "_").replace("/", "_").replace(":", "_").replace("(", "").replace(")", "")


func _cleanup():
	instance.queue_free()
