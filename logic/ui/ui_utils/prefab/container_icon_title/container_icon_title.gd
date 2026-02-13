@tool
extends Container


@export_category("Text S")
@export var title_text: String = "Some title":
	set(value):
		title_text = value
		_update_title()
## -1 means default will be used
@export var title_text_size: int = -1:
	set(value):
		title_text_size = value
		_update_title()
@export var title_font: Font:
	set(value):
		title_font = value
		_update_title()


@export_category("Icon S")
@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_update_icon()

@export var icon_color: Color = Color.WHITE:
	set(value):
		icon_color = value
		_update_icon()

@onready var _icon_rect: TextureRect = %Icon
@onready var _title_lbl: Label = %CGTitle


func _ready() -> void:
	_update_title()
	_update_icon()


func _update_title() -> void:
	if not is_node_ready():
		return

	if not _title_lbl:
		return
	
	_title_lbl.text = title_text


	if title_text_size != -1:
		ControlUtils.label_set_font_size(_title_lbl, title_text_size)
	if title_font:
		ControlUtils.label_set_font(_title_lbl, title_font)


func _update_icon() -> void:
	if not is_node_ready():
		return

	
	if _icon_rect:
		_icon_rect.texture = icon_texture
		_icon_rect.modulate = icon_color
		_icon_rect.visible = icon_texture != null
