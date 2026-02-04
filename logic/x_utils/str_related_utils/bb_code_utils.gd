class_name BB
extends RefCounted


static func color_wrap(text: String, color_hex: String) -> String:
	return "[color=%s]%s[/color]" % [color_hex, text]


static func i_wrap(text: String) -> String:
	return "[i]%s[/i]" % text


static func b_wrap(text: String) -> String:
	return "[b]%s[/b]" % text


static func image_20_wrap(text: String) -> String:
	return image_wrap(text, 20)


static func image_wrap(text: String, size: int = 20) -> String:
	if size > 0:
		return "[img=%dx%d]%s[/img]" % [size, size, text]
	return "[img]%s[/img]" % text