@tool
extends EditorScript

const TARGET_FOLDER = "res://-assets-/GLB-char/player/pl-skeleton-ranger/"
const IMAGE_EXTENSIONS = ["jpg", "jpeg", "png"]

## WARNING WIP
## DANGER NOT WORKING!!!

func _run():
	__log_script.start_("UNUSED IMAGE FINDER")
	
	var all_images = _get_all_images_in_folder(TARGET_FOLDER)
	var used_files = _get_all_used_files()
	
	__log_script.info_("", "Total images found:", all_images.size())
	__log_script.info_("", "Total used files:", used_files.size())
	
	var unused_images: Array[String] = []
	for img_path in all_images:
		if not img_path in used_files:
			unused_images.append(img_path)
	
	__log_script.info_("", "Unused images:", unused_images.size())
	
	if unused_images.is_empty():
		__log_script.info_("✅", "All images are in use!")
	else:
		for unused in unused_images:
			__log_script.info_("🗑️", "Unused:", unused)
	
	__log_script.end_("UNUSED IMAGE FINDER")


func _get_all_images_in_folder(folder_path: String) -> Array[String]:
	var images: Array[String] = []
	var dir = DirAccess.open(folder_path)
	
	if not dir:
		__log_script.error_("", "Cannot open folder", folder_path, "")
		return images
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			var ext = file_name.get_extension().to_lower()
			if ext in IMAGE_EXTENSIONS:
				images.append(folder_path + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return images


func _get_all_used_files() -> Dictionary:
	var used_files: Dictionary = {}
	
	# Get all resources in project
	var filesystem = EditorInterface.get_resource_filesystem()
	_scan_directory(filesystem.get_filesystem(), used_files)
	
	return used_files


func _scan_directory(dir: EditorFileSystemDirectory, used_files: Dictionary) -> void:
	# Scan files in this directory
	for i in range(dir.get_file_count()):
		var file_path = dir.get_file_path(i)
		
		# Get dependencies of this resource
		var deps = ResourceLoader.get_dependencies(file_path)
		for dep in deps:
			used_files[dep] = true
	
	# Recursively scan subdirectories
	for i in range(dir.get_subdir_count()):
		_scan_directory(dir.get_subdir(i), used_files)
