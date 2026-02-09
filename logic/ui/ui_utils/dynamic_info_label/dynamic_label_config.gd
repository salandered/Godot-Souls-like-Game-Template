class_name DynamicLabelConfig
extends RefCounted


var from_snake_case: bool
var animate_prev: bool
var adjust_prev_font_size: bool
var in_bold: bool
var in_italics: bool
var override_color: Color


func _init(
	from_snake_case_: bool = false,
	animate_prev_: bool = false,
	adjust_prev_font_size_: bool = false,
	in_bold_: bool = false,
	in_italics_: bool = false,
	override_color_: Color = Color(0, 0, 0),
):
	self.from_snake_case = from_snake_case_
	self.animate_prev = animate_prev_
	self.adjust_prev_font_size = adjust_prev_font_size_
	self.in_bold = in_bold_
	self.in_italics = in_italics_
	self.override_color = override_color_
