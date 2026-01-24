@tool
extends DynamicInfoLabel
class_name DynamicInfoLabelDouble


@onready var _second_text_label: RichTextLabel = %Text2


var _active_ghosts_second: Array[RichTextLabel] = []

func _ready() -> void:
	super._ready()
	if not Engine.is_editor_hint():
		set_second_text_label("")


func reset_text() -> void:
	super.reset_text()
	set_second_text_label("")
	_active_ghosts_second = []


func set_second_text_label(new_text: String, dynamic_label_config: DynamicLabelConfig = null) -> void:
	_set_label_text(_active_ghosts_second, _second_text_label, new_text, dynamic_label_config)


## 


func _update_font_size() -> void:
	super._update_font_size()
	if _second_text_label:
		UIUtils.rr_label_set_font_size(_second_text_label, font_size)
