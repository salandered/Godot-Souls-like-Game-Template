@tool
extends EditorScript

const TARGET_FOLDER = "res://-assets-/ui_assets/loader_backgrounds/"
const IMAGE_EXTENSIONS = ["jpg", "jpeg", "png"]
const IGNORE_WORDS = ["pixel", "pixpal"]

## If true, actually performs the conversion. 
## If false, just logs what it WOULD do.
const PERFORM_CONVERSION = false

var non_8_count: int = 0
var already_8_count: int = 0

## FORMAT_RGB8 = 4
##
## FORMAT_RGBA8 = 5
## FORMAT_RG8 = 3

func _run():
	__log_script.start_("SMART FORMAT OPTIMIZER")
	_scan_and_process()
	if PERFORM_CONVERSION:
		EditorInterface.get_resource_filesystem().scan()
	__log_script.end_("SMART FORMAT OPTIMIZER")

func _scan_and_process():
	var dir = DirAccess.open(TARGET_FOLDER)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			_analyze_file(TARGET_FOLDER, file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _analyze_file(folder: String, file_name: String):
	# 1. Filter extensions and ignore words
	var ext: String = file_name.get_extension().to_lower()
	
	if not ext in IMAGE_EXTENSIONS: 
		#__log_script.info_("extension is not supported", ext)
		return
	
	for word in IGNORE_WORDS:
		if word in file_name.to_lower(): 
			__log_script.info_("ignored", word, file_name.to_lower())
			return

	var full_path = folder + "/" + file_name
	
	# 2. Load Image
	var texture = load(full_path) as Texture2D
	if not texture: 
		__log_script.info_("if not texture")
		return
	var img = texture.get_image()
	if not img: 
		__log_script.info_("if not img")
		return
	
	# Decompress if needed to read format/pixels
	if img.is_compressed():
		__log_script.info_("decompress")
		img.decompress()

	var fmt = img.get_format()
	__log_script.info_("fmt", fmt)
	# --- LOGIC START ---
	
	# CASE: RGBA (Format 5)
	if fmt == Image.FORMAT_RGBA8:
		# Check if alpha is actually used
		var alpha_status = img.detect_alpha()
		
		if alpha_status == Image.ALPHA_NONE:
			__log_script.info_("🎨 OPTIMIZE", "RGBA8 found but Alpha is unused (Opaque). Converting to RGB8...", pp.in_q(file_name))
			if PERFORM_CONVERSION:
				img.convert(Image.FORMAT_RGB8)
				_save_image(img, full_path, ext)
		else:
			__log_script.info_("⏭️ SKIP", "RGBA8 found and Alpha IS used. Keeping.", pp.in_q(file_name))

	# CASE: RG (Format 3)
	elif fmt == Image.FORMAT_RG8:
		__log_script.info_("⏭️ SKIP", "RG8 found. Likely intentional packed map. Keeping.", pp.in_q(file_name))

	# CASE: already RGB (Format 4)
	elif fmt == Image.FORMAT_RGB8:
		pass # Do nothing, this is ideal

	# CASE: L8 (Grayscale) or others
	else:
		pass
		# __log_script.info_("ℹ️ INFO", "Found other format", fmt, file_name)

func _save_image(img: Image, path: String, ext: String):
	var err = OK
	match ext:
		"jpg", "jpeg": err = img.save_jpg(path, 0.9)
		"png": err = img.save_png(path)
	
	if err != OK:
		__log_script.error_("SAVE", "Failed to save", path, err)
	else:
		__log_script.info_("✅", "Saved", path.get_file())
