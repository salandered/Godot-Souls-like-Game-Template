@tool
extends EditorContextMenuPlugin

const ACTION_ID := 1001
const TARGET_ROOT_FOLDER := "res://-assets-/animations/standard-skeleton/"

const filesystem_feature := "filesystem"

var editor_interface: EditorInterface

func _setup(editor_interface_: EditorInterface) -> void:
	print("Setting up Animation Extractor plugin.")
	editor_interface = editor_interface_

func _has_support_for(feature: String) -> bool:
	# This can be noisy, so it's commented out. Uncomment for deep debugging.
	# print("Checking support for feature: ", feature)
	return feature == filesystem_feature

func _populate_menu(menu: PopupMenu, feature: String) -> void:
	if feature != filesystem_feature:
		return
	
	var selected_files = editor_interface.get_resource_file_system().get_selected_files()
	if selected_files.size() == 1 and selected_files[0].ends_with(".glb"):
		print("Found a .glb file, adding menu item.")
		menu.add_separator()
		menu.add_item("Extract Animations", ACTION_ID)

func _handle_menu_option(feature: String, id: int) -> void:
	if feature != filesystem_feature or id != ACTION_ID:
		return
	
	print("--- 'Extract Animations' option selected ---")
	var selected_files = editor_interface.get_resource_file_system().get_selected_files()
	if selected_files.is_empty():
		print("No files selected, aborting.")
		return
	
	var glb_path: String = selected_files[0]
	process_glb_file(glb_path)

func process_glb_file(file_path: String):
	print("Processing file: ", file_path)
	var packed_scene: PackedScene = ResourceLoader.load(file_path)
	
	if not packed_scene:
		push_warning("Couldn’t load scene resource: " + file_path)
		print("ERROR: Failed to load PackedScene from path.")
		return

	print(" > Scene resource loaded successfully.")
	
	var instance = packed_scene.instantiate()
	if not instance:
		push_error("Failed to instantiate scene: " + file_path)
		print("ERROR: Failed to instantiate scene from PackedScene.")
		return
	
	print(" > Scene instantiated successfully.")

	# Using your preferred hardcoded path.
	var anim_player_path := "Armature/AnimationPlayer"
	print(" > Searching for AnimationPlayer at: ", anim_player_path)
	var anim_player := instance.get_node_or_null(anim_player_path) as AnimationPlayer
	
	if not anim_player:
		push_warning("No AnimationPlayer found at '%s' in: %s" % [anim_player_path, file_path])
		print("WARNING: AnimationPlayer node not found at the specified path.")
		instance.queue_free() # Clean up the unused instance.
		return

	print(" > Found AnimationPlayer: ", anim_player.name)
		
	var base_name := file_path.get_file().get_basename()
	var target_dir := TARGET_ROOT_FOLDER.path_join(base_name)
	print(" > Target directory for animations: ", target_dir)
	
	var err_dir = DirAccess.make_dir_recursive_absolute(target_dir)
	if err_dir != OK:
		push_error("Failed to create directory: %s (Error code: %d)" % [target_dir, err_dir])
		print("ERROR: Could not create target directory.")
		instance.queue_free()
		return
	
	var animation_list = anim_player.get_animation_list()
	print(" > Found %d animations to extract: %s" % [animation_list.size(), animation_list])

	for anim_name in animation_list:
		var anim: Animation = anim_player.get_animation(anim_name)
		var copied_anim := anim.duplicate()
		var save_name := _sanitize(anim_name) + ".res"
		var save_path := target_dir.path_join(save_name)
		
		print("   - Saving '%s' to '%s'" % [anim_name, save_path])
		
		var err_save := ResourceSaver.save(copied_anim, save_path)
		if err_save != OK:
			push_warning("Failed to save animation: " + save_path)
			print("   - ERROR: Failed to save animation (Code: %d)" % err_save)
		else:
			print("   - Success!")

	# Clean up the instantiated scene from memory after we're done.
	instance.queue_free()
	print(" > Instance cleaned up from memory.")
	print("✔ Finished extraction process for: ", base_name)
	print("--- End of process ---")


func _sanitize(name: String) -> String:
	# Added ':' to the list of characters to replace, as it's common in animation names.
	return name.replace(" ", "_").replace("/", "_").replace(":", "-")
