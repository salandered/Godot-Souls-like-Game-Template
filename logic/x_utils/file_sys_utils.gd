class_name FileSystemUtils
extends RefCounted

## Loads all images from a directory recursively.
## Set sort_files to false if you want the original file system order (often random/fastest).
static func load_images_recursive(root_path: String, sort_files: bool = true) -> Array[Texture2D]:
	var paths = get_image_paths_recursive(root_path)
	
	if sort_files:
		paths.sort()
	
	var textures: Array[Texture2D] = []
	for path in paths:
		var tex = load(path)
		if tex is Texture2D:
			textures.append(tex)
	return textures


static func get_image_paths_recursive(path: String) -> Array[String]:
	var paths: Array[String] = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					paths.append_array(get_image_paths_recursive(path + "/" + file_name))
			else:
				if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
					paths.append(path + "/" + file_name)
			
			file_name = dir.get_next()
	return paths