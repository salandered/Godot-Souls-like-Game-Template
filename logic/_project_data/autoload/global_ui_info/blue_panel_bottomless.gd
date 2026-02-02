@tool
@icon("uid://wsstt2x2so8p")
extends MarginContainer
class_name BluePanelBottomless


const TITLE_NODE_NAME = "BluePanelTitle"
var _title: RichTextLabel

@export var title_text: String = "no title":
	set(value):
		title_text = value
		_update_title_text()


func _ready():
	_update_title_text()
	
	
func _update_title_text():
	var titles := get_descendants.rich_text_labels(self )
	for item in titles:
		if item.name == TITLE_NODE_NAME:
			_title = item
	var _r := "[b][i]" + title_text + "[/i][/b]"

	if _title:
		_title.text = _r
	else:
		if not Engine.is_editor_hint():
			error_.warn("no title", "", "", WL.WARN_CRUCIAL, name, self , title_text)
