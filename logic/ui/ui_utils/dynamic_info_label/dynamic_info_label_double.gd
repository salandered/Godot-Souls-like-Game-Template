@tool
extends DynamicInfoLabel
class_name DynamicInfoLabelDouble


@onready var _second_text_label: RichTextLabel = %Text2


## NOTE: used in editor for preview only
@export var in_editor_second_label_text: String = "another":
	set(value):
		in_editor_second_label_text = value
		_update_in_editor_label_text()


var _active_ghosts_second: Array[RichTextLabel] = []


func _ready() -> void:
	super._ready()
	if not u.is_editor():
		set_second_text_label("")


func reset_text() -> void:
	super.reset_text()
	set_second_text_label("")
	_active_ghosts_second = []


func set_second_text_label(new_text: String, dynamic_label_config: DynamicLabelConfig = null, ignore_font_size_adjustment: bool = false) -> void:
	_set_label_text(_active_ghosts_second, _second_text_label, new_text, dynamic_label_config, ignore_font_size_adjustment)


## 


func _update_font_size() -> void:
	super._update_font_size()
	if _second_text_label:
		ControlUtils.rr_label_set_font_size(_second_text_label, font_size)


func _update_in_editor_label_text() -> void:
	super._update_in_editor_label_text()
	if u.is_editor():
		set_second_text_label(in_editor_second_label_text)
