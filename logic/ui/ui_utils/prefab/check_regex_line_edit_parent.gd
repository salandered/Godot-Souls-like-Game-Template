extends Node

@export var invalid_color: Color = Color(1, 0.4, 0.4)

var _parent: LineEdit


func _ready() -> void:
	_parent = get_parent() as LineEdit
	if _parent:
		_parent.text_changed.connect(_on_text_changed)
		_on_text_changed(_parent.text)


func _on_text_changed(new_text: String) -> void:
	var info := ReUtils.check_regex_compile(new_text)
	if not _parent: return
	
	if info.is_valid:
		_parent.remove_theme_color_override("font_color")
	else:
		_parent.add_theme_color_override("font_color", invalid_color)