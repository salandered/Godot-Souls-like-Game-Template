extends RefCounted
class_name pp

static var __ := " " # todo: is it a safe name :D
static var cln := ": "
static var s_cln := "; "
static var arr := " -> "
static var hence := " => "


static func ts(...parts: Array) -> String:
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

static func in_sp(something: Variant) -> String:
	return " " + str(something) + " "

static func compare(what_happened: String, text_1: String, val_1: float, text_2: String, val_2: float) -> String:
	# what_happened e.g.: "works longer than"
	var r = ts(text_1, round_01(val_1), what_happened, text_2, round_01(val_2))
	return r

static func compare_w(what_happened: String, text_2: String, val_2: float) -> String:
	# what_happened e.g.: "works longer than"
	var r = ts(what_happened, text_2, round_01(val_2))
	return r

static func pp_vec3(v: Vector3) -> String:
	return "(%2.2f %2.2f %2.2f)" % [v.x, v.y, v.z]


static func pp_vec2(v: Vector2) -> String:
	return "(%2.2f %2.2f)" % [v.x, v.y]

static func round_01(f: float) -> String:
	assert(f is float)
	return str(snapped(f, 0.01))


static func pp_v3_angle_deg(a: Vector3, b: Vector3, to_str: bool = true) -> Variant:
	var r = rad_to_deg(a.normalized().angle_to(b.normalized()))
	r = snapped(r, 0.00001)
	if to_str:
		return str(r)
	return r


static func pp_file_load_err(err, path: String):
	if err == OK:
		print(path + " loaded successfully")
	elif err == ERR_DOES_NOT_EXIST:
		print(path + " no file found")
	else:
		print(path + " error loading:", err)
