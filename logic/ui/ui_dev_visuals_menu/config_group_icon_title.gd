@tool
extends Container

@export var title_text: String = "Some title":
	set(value):
		title_text = value
		_update_visuals()

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_update_visuals()

@export var icon_color: Color = Color.WHITE:
	set(value):
		icon_color = value
		_update_visuals()

@onready var _icon_rect: TextureRect = %Icon
@onready var _title_lbl: Label = %CGTitle

func _ready() -> void:
	_update_visuals()

func _update_visuals() -> void:
	if not is_node_ready():
		return

	if _title_lbl:
		_title_lbl.text = title_text
	
	if _icon_rect:
		_icon_rect.texture = icon_texture
		_icon_rect.modulate = icon_color
		_icon_rect.visible = icon_texture != null
