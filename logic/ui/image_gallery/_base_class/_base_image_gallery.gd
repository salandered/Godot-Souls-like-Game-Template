@abstract
class_name BaseImageGallery
extends ControlSystem


const BASE_PATH := "res://-assets-/ui_assets/gallery/"
const MISC_PATH := BASE_PATH + "misc/"


## will be used recursively
@export_dir var IMAGES_PATH = BASE_PATH

## parent of all
@onready var global_container: MarginContainer = %GlobalContainer

@onready var image_display: TextureRect = %Display

@onready var system_info_container: PanelContainer = %SystemInfoContainer
@onready var system_info_label: Label = %SystemInfoLabel


@onready var legend_container: MarginContainer = %LegendContainer
@onready var legend_label: RichTextLabel = %LegendLabel

@onready var info_container: PanelContainer = %InfoContainer
@onready var title_container: MarginContainer = %TitleContainer
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_container: MarginContainer = %DescriptionContainer
@onready var description_label: RichTextLabel = %DescriptionLabel

@onready var counter_container: MarginContainer = %CounterContainer
@onready var counter_label: RichTextLabel = %CounterLabel
	
@onready var book_flip_asp: AudioStreamPlayer = $asp/BookFlip


var _raw_gallery_items: Array[GalleryItem] = []
var populated_gallery_items: Array[GalleryItem] = []
var curr_item_idx: int = 0

var _is_gallery_initialised: bool = false

var _ui_layer_visible: bool = true

var transition_tween: Tween
var ui_tween: Tween

const DEFAULT_GLOBAL_MARGIN: int = 60


func __hard_dependencies() -> Array:
	return [
		global_container,
		image_display,
		system_info_container,
		system_info_label,
		info_container,
		title_label,
		description_label,
		counter_container,
		counter_label,
		legend_container,
		legend_label
	]

func __soft_dependencies() -> Array:
	return [
		book_flip_asp,
	]

func __hard_validation() -> bool:
	var _r: bool = true
	if error_.empty_list(get_raw_gallery_items(), "_raw_gallery_items", WL.WARN):
		_r = false
	return _r


@abstract func get_raw_gallery_items() -> Array[GalleryItem]


const base_legend_text := "[b]← → or A/D[/b] - Next/Prev
[b]0[/b] - Toggle UI
[i]Esc - Back to main menu[/i]
"

func get_legend_text() -> String:
	return base_legend_text


## INIT
# region

func _ready():
	if not __perform_validation():
		__log_warn_soft("ImageGallery won't be working")
		return

	set_system_info_container_visible(true)
	set_system_info_text("Loading Gallery ...")
	set_counter_container_visible(false)
	set_legend_container_visible(false)
	set_legend_text(get_legend_text())
	image_display.visible = false
	ControlUtils.margin_container_set_margins(global_container, DEFAULT_GLOBAL_MARGIN, DEFAULT_GLOBAL_MARGIN)

	curr_item_idx = 0
	populated_gallery_items.clear()

	# defer execution to let the UI draw laoding label before the freeze starts
	call_deferred("_initialise_gallery")


func _initialise_gallery():
	for item: GalleryItem in get_raw_gallery_items():
		if not item:
			__log_warn_soft("item is null in get_raw_gallery_items")
			continue

		var full_path = item.get_file_path()
		
		if ResourceLoader.exists(full_path):
			var _loaded_texture := load(full_path)
			
			if _loaded_texture and _loaded_texture is Texture2D:
				item.texture = _loaded_texture
				populated_gallery_items.append(item)
			else:
				__log_warn_soft("Loaded resource is not a Texture2D: " + full_path)
		else:
			__log_warn_soft(pp.s("File path not found:", full_path))


	if not error_.empty_list(populated_gallery_items, "populated_gallery_items", WL.WARN):
		__log_("_initialise_gallery", len(populated_gallery_items), "gallery items are populated and ready")
		_is_gallery_initialised = true
		set_system_info_container_visible(false)
		set_counter_container_visible(true)
		set_legend_container_visible(true)
		image_display.visible = true
		update_display()
	else:
		_is_gallery_initialised = false
		set_system_info_container_visible(true)
		set_system_info_text("Gallery Error: No matching files found.")

# endregion


## public API

func is_gallery_initialised() -> bool:
	return _is_gallery_initialised

##


func _get_curr_gallery_item_from_list() -> GalleryItem:
	if populated_gallery_items.is_empty():
		__log_warn_soft("curr_item_idx problem. should not happen here", "", "", curr_item_idx)
		return

	if curr_item_idx < 0 or curr_item_idx >= populated_gallery_items.size():
		__log_warn_soft("curr_item_idx problem. should not happen here", "", "", curr_item_idx)
		return
	
	var item := populated_gallery_items[curr_item_idx]
	return item
	

func update_display():
	__log_("update_display", "showing item with index", curr_item_idx)

	var item := _get_curr_gallery_item_from_list()

	# collect all UI elements we want to fade
	var targets_to_animate: Array[Control] = [image_display]
	if info_container:
		targets_to_animate.append(info_container)
	
	UIUtils.kill_tween_if_exists(transition_tween)
	
	transition_tween = UIUtils.animate_content_change(
		self ,
		targets_to_animate,
		func(): _switch_ui_to_gallery_item(item),
		0.15
	)

	_update_counter_text()


func _update_counter_text() -> void:
	if counter_label:
		# Format: "1 / 10"
		counter_label.text = "%d / %d" % [curr_item_idx + 1, populated_gallery_items.size()]


func _switch_ui_to_gallery_item(item: GalleryItem):
	image_display.texture = item.texture
	
	title_container.visible = item.has_title()
	title_label.text = "[center]" + item.title
	
	description_container.visible = item.has_description()
	description_label.text = item.description

	info_container.visible = _ui_layer_visible and (item.has_title() or item.has_description())


## direction is +1 or -1
func change_item(direction: int):
	if populated_gallery_items.is_empty():
		__log_warn_soft("curr_item_idx problem. should not happen here", "", "", curr_item_idx)
		return
		
	curr_item_idx = (curr_item_idx + direction + populated_gallery_items.size()) % populated_gallery_items.size()

	__log_("change_image", "new index calculated", curr_item_idx)

	update_display()


## 


## Container wrappers

func set_system_info_text(text: String):
	system_info_label.text = text


func set_legend_text(text: String):
	legend_label.text = text


func set_system_info_container_visible(value: bool):
	system_info_container.visible = value
	system_info_label.visible = value


func set_counter_container_visible(value: bool):
	counter_container.visible = value
	counter_label.visible = value


func set_legend_container_visible(value: bool):
	legend_container.visible = value
	legend_label.visible = value


##

func _apply_ui_visibility():
	# system_info_container is always hidden after the initialisation
	set_counter_container_visible(_ui_layer_visible)
	set_legend_container_visible(_ui_layer_visible)
	
	if _ui_layer_visible:
		var item := _get_curr_gallery_item_from_list()
		var has_content = item.has_title() or item.has_description()
		info_container.visible = _ui_layer_visible and has_content
	else:
		info_container.visible = _ui_layer_visible

	var target_margin := DEFAULT_GLOBAL_MARGIN if _ui_layer_visible else 0
	
	# (assuming L and R are synced)
	var current_margin := global_container.get_theme_constant(PropC.MARGIN_LEFT)
	
	UIUtils.kill_tween_if_exists(ui_tween)
	ui_tween = create_tween()
	ui_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	ui_tween.tween_method(_update_global_margins, current_margin, target_margin, 0.2)
	# if _ui_layer_visible:
	# 	ControlUtils.margin_container_set_margins(global_container, DEFAULT_GLOBAL_MARGIN, DEFAULT_GLOBAL_MARGIN)
	# else:
	# 	ControlUtils.margin_container_set_margins(global_container, 0, 0)


func _update_global_margins(value: int) -> void:
	# This function will be called every frame by the tween
	ControlUtils.margin_container_set_margins(global_container, value, value)

## Input

func _input(event):
	if not is_visible_in_tree() or not _is_gallery_initialised:
		return

	match InputUtils.get_keycode(event):
		KEY_D, KEY_RIGHT:
			change_item(1)
			_play_book_flip()
			get_viewport().set_input_as_handled()
		KEY_A, KEY_LEFT:
			change_item(-1)
			_play_book_flip()
			get_viewport().set_input_as_handled()
		KEY_0, KEY_KP_0:
			_ui_layer_visible = not _ui_layer_visible
			_apply_ui_visibility()
			get_viewport().set_input_as_handled()


func _play_book_flip() -> void:
	if book_flip_asp:
		book_flip_asp.play()
