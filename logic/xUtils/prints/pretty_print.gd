extends RefCounted
class_name pp

static var __ := " " # todo: is it a safe name :D
static var cln := ": "
static var s_cln := "; "
static var arr := " -> "
static var hence := " => "
static var angle := " ∠ "

static var on_ent := " on-entr "
static var on_ex := " on-exit "

static func s(...parts: Array) -> String:
	var r = ""
	for part in parts:
		if part is float:
			r += str(pp.round_01(part)) + " "
		else:
			r += str(part) + " "
	return r

static func in_q(something: Variant, spaces: bool = false) -> String:
	var r = "'" + str(something) + "'"
	return in_sp(r) if spaces else r

static func in_sq(something: Variant, spaces: bool = false) -> String:
	var r = "[" + str(something) + "]"
	return in_sp(r) if spaces else r


static func in_br(something: Variant, spaces: bool = false) -> String:
	var r = "(" + str(something) + ")"
	return in_sp(r) if spaces else r

static func in_sp(something: Variant) -> String:
	return " " + str(something) + " "

static func compare(what_happened: String, text_1: String, val_1: float, text_2: String, val_2: float) -> String:
	# what_happened e.g.: "works longer than"
	var r = s(text_1, round_01(val_1), what_happened, text_2, round_01(val_2))
	return r

static func compare_w(what_happened: String, text_2: String, val_2: float) -> String:
	# what_happened e.g.: "works longer than"
	var r = s(what_happened, text_2, round_01(val_2))
	return r

static func _dict(dict_: Dictionary, json: bool = false) -> String:
	if json:
		return JSON.stringify(dict_, "\t")
	if dict_.is_empty():
		return "{}"
	var r = ""
	for key_ in dict_.keys():
		var value_ = dict_[key_]
		if value_ is float:
			value_ = round_01(value_)
		r += in_q(key_) + " -> " + in_q(value_) + '\n'
	return r.strip_edges()


static func _array(array_: Array, json: bool = false) -> String:
	if json:
		return JSON.stringify(array_, "\t")
	if array_.size() == 0:
		return "[empty]"
	var r = ""
	for item in array_:
		r += " " + str(item)
	return r.strip_edges()

static func vec3(v: Vector3) -> String:
	return "(%3.3f %3.3f %3.3f)" % [v.x, v.y, v.z]


static func vec2(v: Vector2) -> String:
	return "(%4.2f %4.2f)" % [v.x, v.y]

static func round_01(f: float) -> String:
	assert(f is float)
	return str(snapped(f, 0.01))


static func vec3_angle_deg(a: Vector3, b: Vector3, to_str: bool = true) -> Variant:
	var r = rad_to_deg(a.normalized().angle_to(b.normalized()))
	r = snapped(r, 0.00001)
	if to_str:
		return str(r)
	return r


static func rad2deg(angle: float, to_str: bool = true) -> Variant:
	var r = rad_to_deg(angle)
	r = snapped(r, 0.01)
	if to_str:
		return str(r) + "°"
	return r


static func file_load_err(err, path: String):
	if err == OK:
		print(path + " loaded successfully")
	elif err == ERR_DOES_NOT_EXIST:
		print(path + " no file found")
	else:
		print(path + " error loading:", err)
