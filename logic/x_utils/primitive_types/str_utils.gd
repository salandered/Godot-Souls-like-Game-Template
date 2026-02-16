class_name StrUtils
extends RefCounted


static func snake_to_sentence(text: String) -> String:
	var clean := text.replace("_", " ")
	
	if clean.is_empty():
		return ""
		
	# substr(1) is ok if len is 1.
	return clean[0].to_upper() + clean.substr(1)


static func to_pascal_case(snake_case: String) -> String:
	var words := snake_case.split("_")
	var result := ""
	for word in words:
		if word.length() > 0:
			result += word.capitalize()
	return result


static func cut_string(text: String, limit: int = 600) -> String:
	if text.length() <= limit:
		return text
	return text.left(limit) + " ... <too long to print>"


## awed/name -> name; 
## awd/awdaw/name -> name; 
## ../awd/name -> name; 
## name -> name; 
## /name -> name; 
## name/ -> ''; 
static func get_last_slash_part(raw_string: String) -> String:
	# NOTE: looks like built in get_file will do. But this is custom approach.
	## var pos = raw_string.rfind("/")
	## var _r = raw_string.substr(pos + 1) if pos != -1 else raw_string
	var _r = raw_string.get_file()
	return _r


static func calculate_tab_prefix(indents: int) -> String:
	var cache: Dictionary[int, String] = {
		0: "",
		1: "    ",
		2: "        ",
		3: "            ",
		4: "                ",
		5: "                    ",
		6: "                        ",
		7: "                            ",
		8: "                                ",
		10: "                                        ",
		12: "                                                ",
		16: "                                                                ",
	}
	if cache.has(indents):
		return cache[indents]

	var tabs_prefix := ""
	if indents:
		for i in range(indents):
			tabs_prefix += "    "
	return tabs_prefix


## WARNING: dict key are not ordered i suppose
static func replace_text_fragments(text: String, replacers: Dictionary[String, String]):
	for key_word: String in replacers:
		text = text.replace(key_word, replacers[key_word])
	text = text.strip_edges()
	return text


## TODO: weird, not here

static func pp_name_replacers(_r: String) -> String:
	for key_word: String in _pp_replacers:
		_r = _r.replace(key_word, _pp_replacers[key_word])
	return _r


static var _pp_replacers: Dictionary[String, String] = {
		"Container": em.box,
		"Player": "Pl",
		"Character": "Char",
		"Enemy": "🗿",
		"Feelings": em.h_white,
		"Weapon": em.dagger,
		"Awareness": "👀",
		"ModifierAnimator": "💀Animator"
	}
