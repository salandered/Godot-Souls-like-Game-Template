@tool
extends EditorScript

const ROOT_DIR = "res://-assets-/materials-shared/"
const IMAGE_EXTENSIONS = ["png", "jpg", "jpeg", "tga", "bmp", "webp"]
const IGNORE_WORDS = ["pixel", "pixpal", "lut"]

## WARNING: not sure this works, also it's heavy
const ENABLE_PIXEL_ANALYSIS = false

const IMPORT_MODE_LOSSLESS = 0

var count_scanned := 0
var count_import_issues := 0 # Lossless or No Mipmaps
var count_pixel_issues := 0 # Unused Alpha (RGBA -> RGB opportunity)


func _run() -> void:
	count_scanned = 0
	count_import_issues = 0
	count_pixel_issues = 0
	
	__log_script.info_("🔍 FULL TEXTURE AUDIT", "Recursive Scan:", ROOT_DIR)
	
	_scan_folder_recursive(ROOT_DIR)
	
	__log_script.info_("📊 RESULTS",
		"Scanned:", count_scanned,
		"Import Settings Issues:", count_import_issues,
		"Pixel Format Optimizations:", count_pixel_issues)
		
	__log_script.info_("FULL TEXTURE AUDIT")


func _scan_folder_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		__log_script.error_("Could not open directory", path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path := path.path_join(file_name)

		if dir.current_is_dir():
			_scan_folder_recursive(full_path)
		else:
			# file check
			var ext := file_name.get_extension().to_lower()
			if ext in IMAGE_EXTENSIONS:
				if _should_ignore(file_name):
					pass
				else:
					_analyze_texture(full_path, file_name)
		
		file_name = dir.get_next()


func _should_ignore(file_name: String) -> bool:
	if file_name.ends_with(".import"): return true
	for word in IGNORE_WORDS:
		if word in file_name.to_lower(): return true
	return false


func _analyze_texture(file_path: String, file_name: String) -> void:
	count_scanned += 1
	
	# Checks .import file for "Lossless" or "No Mipmaps"
	var import_issue_found := _audit_import_settings(file_path, file_name)
	if import_issue_found:
		count_import_issues += 1
		
	# Loads image to check if RGBA is using transparency
	if ENABLE_PIXEL_ANALYSIS:
		var pixel_issue_found := _audit_pixel_format(file_path, file_name)
		if pixel_issue_found:
			count_pixel_issues += 1


func _audit_import_settings(file_path: String, file_name: String) -> bool:
	var import_path := file_path + ".import"
	if not FileAccess.file_exists(import_path):
		return false # Not imported yet

	var config := ConfigFile.new()
	var err := config.load(import_path)
	if err != OK: return false

	var type = config.get_value("remap", "type", "")
	if type != "Texture2D": return false

	var compress_mode = config.get_value("params", "compress/mode", -1)
	var mipmaps = config.get_value("params", "mipmaps/generate", false)
	
	var issues: Array[String] = []
	if compress_mode == IMPORT_MODE_LOSSLESS:
		issues.append("LOSSLESS (High VRAM)")
	if not mipmaps:
		issues.append("NO MIPMAPS")
		
	if not issues.is_empty():
		var msg := " + ".join(issues)
		__log_script.info_("⚠️ IMPORT SETTINGS", msg, pp.in_q(file_name))
		return true
		
	return false


func _audit_pixel_format(file_path: String, file_name: String) -> bool:
	var texture = load(file_path) as Texture2D
	if not texture: return false
	
	var img := texture.get_image()
	if not img: return false
	
	if img.is_compressed():
		img.decompress() # Needed to check pixels
	
	var fmt := img.get_format()
	
	# Check for RGBA8 (Format 5) with unused Alpha
	if fmt == Image.FORMAT_RGBA8:
		if img.detect_alpha() == Image.ALPHA_NONE:
			__log_script.info_("🎨 PIXEL FORMAT", "RGBA8 found but Alpha is unused.", "Can be RGB8", pp.in_q(file_name))
			return true
			
	return false
