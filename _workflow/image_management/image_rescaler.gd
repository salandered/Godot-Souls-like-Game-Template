@tool
extends EditorScript

const TARGET_FOLDER = "res://-assets-/GLB-char/godot_plush/"
#const TARGET_FOLDER = "res://-assets-/materials-shared/_images/"
## WARNING: only jpg and png supported. And use lower case
const IMAGE_EXTENSIONS = ["jpg", "jpeg", "png"]
## will be ignored of contains
const IGNORE_WORDS = ["pixel", "pixpal"]
const TARGET_SCALE_STR = "512" # Options: "256",  "1k", "05k" etc


const OVERWRITE_ORIGINALS = true # true = replace originals, false = create _d1k versions
# if was processed wo overwrite, image has postfix. Whether to skip such files when overwriting
const SKIP_ALREADY_PROCESSED_WHEN_OVERWRITE = true
const FORCE_8BIT_NORMALS = false # Convert normal maps to 8-bit per channel
const NORMAL_MAP_KEYWORDS = ["norm", "normal", "nrm", "nor_gl"]


## Docs
## using INTERPOLATE_LANCZOS
## but could be changed if needed.
# region
## INTERPOLATE_NEAREST = 0
## nearest-neighbor interpolation. If the image is resized, it will be pixelated.
##
## INTERPOLATE_BILINEAR = 1
## bilinear interpolation. If the image is resized, it will be blurry. 
## faster than INTERPOLATE_CUBIC, but lower quality.
##
## INTERPOLATE_CUBIC = 2
## cubic interpolation. If the image is resized, it will be blurry. 
## often gives better results compared to INTERPOLATE_BILINEAR, but slower.
##
## INTERPOLATE_TRILINEAR = 3
## bilinear separately on the two most-suited mipmap levels, then linearly interpolates between them.
## slower than INTERPOLATE_BILINEAR, but higher-quality results with fewer aliasing artifacts.
## If the image does not have mipmaps, they will be generated and used internally, but no mipmaps will be generated on the resulting image.
## > If you intend to scale multiple copies of the original image, it's better to call generate_mipmaps on it in advance, to avoid wasting processing power in generating them again and again.
## > if the image already has mipmaps, they will be used, and a new set will be generated for the resulting image.
##
## INTERPOLATE_LANCZOS = 4
## Lanczos interpolation. 
## Slowest image resizing mode, usually best results when downscaling images.
# endregion


func _run():
	__log_script.start_("IMAGE RESCALER")
	
	_rescale()

	# refresh editor to show new files
	EditorInterface.get_resource_filesystem().scan()

	__log_script.end_("IMAGE RESCALER")


func _rescale():
	var target_image_size := _parse_scale_to_pixels(TARGET_SCALE_STR)
	if target_image_size == -1:
		__log_script.error_("", "Invalid Scale Format", "Config", "Abort", TARGET_SCALE_STR)
		return

	__log_script.info_("", "Using CONFIG",
		"\nTarget Folder:", pp.in_q(TARGET_FOLDER),
		"\nTarget Scale:", pp.in_q(TARGET_SCALE_STR),
		"Image extensions", pp.array_(IMAGE_EXTENSIONS),
		"Mapped to target Size:", pp.in_q(str(target_image_size) + "px"),
		"Suffix would be:", pp.in_q(_get_target_file_suffix()),
		"\nOverwrite originals (if true, no suffix):", OVERWRITE_ORIGINALS,
		"Force 8-bit normals:", FORCE_8BIT_NORMALS)

	var dir := DirAccess.open(TARGET_FOLDER)
	
	if not dir:
		__log_script.error_("", "Cannot open target folder", TARGET_FOLDER, "Abort", DirAccess.get_open_error())
		return

	dir.list_dir_begin()
	var source_file_name := dir.get_next()
	
	while source_file_name != "":
		if not dir.current_is_dir():
			_process_file(dir, source_file_name, target_image_size)
		source_file_name = dir.get_next()
	
	dir.list_dir_end()


func _process_file(dir: DirAccess, source_file_name: String, target_image_size: int):
	var extension_ := source_file_name.get_extension().to_lower()
	var source_base_name := source_file_name.get_basename()

	if not extension_ in IMAGE_EXTENSIONS:
		# __log_script.info_("⏭️", "Skipping unknown extension", source_file_name)
		return
	
	for ignore_word in IGNORE_WORDS:
		if source_base_name.to_lower().contains(ignore_word.to_lower()):
			__log_script.info_("⏭️", "Skipping file with ignored word", pp.in_q(source_file_name), pp.in_q(ignore_word))
			return

	__log_script.info_("🖼️", "Processing file", pp.in_q(source_file_name)) ## main log

	# Only check for suffix if not overwriting originals
	if not OVERWRITE_ORIGINALS or (OVERWRITE_ORIGINALS and SKIP_ALREADY_PROCESSED_WHEN_OVERWRITE):
		if source_base_name.ends_with(_get_target_file_suffix()):
			__log_script.info_("⏭️ 2", "Skipping already processed file", pp.in_q(source_file_name))
			return

	var full_path := TARGET_FOLDER + "/" + source_file_name

	var texture = load(full_path) as Texture2D
	if not texture:
		__log_script.error_("- 2", "Failed to load texture", pp.in_q(source_file_name), "Skipping")
		return

	var img := texture.get_image()

	if not img:
		__log_script.error_("- 2", "Failed to get image from texture", pp.in_q(source_file_name), "Skipping")
		return
	
	var is_normal_map := _is_normal_map(source_file_name)
	# if is_normal_map: __log_script.info_("🗺️ 2", "Detected normal map")
	
	var r := _resize_image(img, target_image_size, is_normal_map)
	if not r:
		return

	# Determine save path
	var target_path: String
	var target_base_name: String
	if OVERWRITE_ORIGINALS:
		target_path = full_path
		target_base_name = source_file_name
	else:
		# example: ground_rocks__d1k.jpg
		target_base_name = source_base_name + _get_target_file_suffix() + "." + extension_
		target_path = TARGET_FOLDER + "/" + target_base_name
	
	var err := OK
	match extension_:
		"jpg", "jpeg": err = img.save_jpg(target_path, 0.9)
		"png": err = img.save_png(target_path)
		_: err = img.save_png(target_path)

	if err == OK:
		var save_type := "Overwritten" if OVERWRITE_ORIGINALS else "Saved as"
		__log_script.info_("🖼️✅ 2",
			"All good for", pp.in_q(source_file_name),
			save_type + ":", pp.in_q(target_base_name)
		)
	else:
		__log_script.error_("- 2", "Failed to save file", target_base_name, "move to next", "Error Code:", err)


func _is_normal_map(filename: String) -> bool:
	var lower_name := filename.to_lower()
	for keyword in NORMAL_MAP_KEYWORDS:
		if keyword in lower_name:
			return true
	return false


## return false in case of problems
func _resize_image(img: Image, target_image_size: int, is_normal_map: bool) -> bool:
	var width := img.get_width()
	var height := img.get_height()
	var max_dim := maxi(width, height)
	
	# Decompress first (needed for both resizing and bit depth conversion)
	if img.is_compressed():
		var err := img.decompress()
		# __log_script.info_("Image was compressed, going to decompress.")
		if err != OK:
			__log_script.error_("- 2", "Failed to decompress image", "Error:", str(err))
			return false
	
	# Convert normal maps to 8-bit (even if not resizing)
	if is_normal_map and FORCE_8BIT_NORMALS:
		_convert_to_8bit(img)
	
	# Check if resize needed
	if max_dim <= target_image_size:
		__log_script.info_("⏭️ 2", "Skipping resize, already <= than target. Size:", _get_size_with_x(width, height), "Target:", pp.in_q(target_image_size))
		# Still return true if we converted bit depth
		return is_normal_map and FORCE_8BIT_NORMALS

	var scale_ratio := float(target_image_size) / float(max_dim)
	var new_width := int(width * scale_ratio)
	var new_height := int(height * scale_ratio)
	

	img.resize(new_width, new_height, Image.INTERPOLATE_LANCZOS)
	__log_script.info_("🖼️✅ 2",
			"Resized to", _get_size_with_x(new_width, new_height),
			"From:", _get_size_with_x(width, height)
		)
	return true

# 🎨
func _convert_to_8bit(img: Image):
	var original_format := img.get_format()
	img.convert(Image.FORMAT_RGB8)
	__log_script.info_("🗺️ 2", "Converted to 8-bit RGB", "From format:", original_format)


func _get_size_with_x(width: int, height: int) -> String:
	return str(width) + "x" + str(height)

func _get_target_file_suffix() -> String:
	return "_d" + TARGET_SCALE_STR

## -1 if cannot parse
func _parse_scale_to_pixels(scale_str: String) -> int:
	match scale_str:
		"1k": return 1024
		"2k": return 2048
		"05k": return 512
		"512": return 512
		"256": return 256
		"128": return 128
		"64": return 64
		_: return -1
