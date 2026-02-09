class_name GalleryItem
extends Resource

var _file_name: String
var _path: String
var title: String
var description: String

var show_title: bool = true
var show_description: bool = true

## expected to be populate at runtime after finding the file
var texture: Texture2D = null


const JPG_FORMAT := ".jpg"

## by default used .jpg for calculating file_path
func _init(file_name_: String, path_: String, title_: String = "", description_: String = "", show_title_: bool = true, show_description_: bool = true) -> void:
	_file_name = file_name_
	_path = path_
	title = title_
	description = description_
	show_title = show_title_
	show_description = show_description_


func get_file_path() -> String:
	return _path + _file_name + JPG_FORMAT


func has_title() -> bool:
	return show_title and not title.is_empty()

func has_description() -> bool:
	return show_description and not description.is_empty()
