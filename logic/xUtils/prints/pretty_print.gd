extends RefCounted
class_name pp

static var __ := " " # todo: is it a safe name :D
static var cln := ": "
static var s_cln := "; "
static var arr := " -> "
static var hence := " => "
static var angle := " ∠ "

static var on_ent := " on-entr↪"
static var on_ext := " on-exit↩"
static var on_upd := " upd"
static var on_internal_upd := " _upd"


static func s(...parts: Array) -> String:
	var r = ""
	for part in parts:
		if part is float:
			r += str(pp.round_01(part)) + " "
		else:
			r += str(part) + " "
	return r


# region: in 

static func in_q(something: Variant, spaces: bool = false) -> String:
	var r := "'" + str(something) + "'"
	return in_sp(r) if spaces else r

static func in_sq(something: Variant, spaces: bool = false) -> String:
	var r := "[" + str(something) + "]"
	return in_sp(r) if spaces else r

static func in_br(something: Variant, spaces: bool = false) -> String:
	var r := "(" + str(something) + ")"
	return in_sp(r) if spaces else r

static func in_curl(something: Variant, spaces: bool = false) -> String:
	var r := "{" + str(something) + "}"
	return in_sp(r) if spaces else r


static func in_sp(something: Variant) -> String:
	return " " + str(something) + " "

# endregion


static func round_001(f: float) -> String:
	assert(f is float)
	return str(snapped(f, 0.001))


static func round_01(f: float) -> String:
	assert(f is float)
	return str(snapped(f, 0.01))


static func vec3_angle_deg(a: Vector3, b: Vector3, to_str: bool = true) -> Variant:
	var r = rad_to_deg(a.normalized().angle_to(b.normalized()))
	r = snapped(r, 0.00001)
	if to_str:
		return str(r)
	return r


static func rad2deg(angle_: float, to_str: bool = true) -> Variant:
	var r = rad_to_deg(angle_)
	r = snapped(r, 0.01)
	if to_str:
		return str(r) + "°"
	return r

# region:  basic structures

static func vec3(v: Vector3) -> String:
	return "(%3.3f %3.3f %3.3f)" % [v.x, v.y, v.z]

static func vec2(v: Vector2) -> String:
	return "(%4.2f %4.2f)" % [v.x, v.y]


static func dict_(_dict_: Dictionary, json: bool = false, one_string: bool = false) -> String:
	if json:
		return JSON.stringify(_dict_, "\t")
	if _dict_.is_empty():
		return "{}"
	return __recursive_dict(_dict_, "", one_string)

static func list_(parts: Array, json: bool = false) -> String:
	if json:
		return JSON.stringify(parts, "\t")
	if parts.size() == 0:
		return "[-x-]"
	var r = ""
	for part in parts:
		if part is float:
			r += str(pp.round_01(part)) + " "
		else:
			r += str(part) + " "
	return r

# endregion

static func file_load_err(err, path: String):
	if err == OK:
		print_.dev(path + " loaded successfully")
	elif err == ERR_DOES_NOT_EXIST:
		print_.dev(path + " no file found")
	else:
		print_.dev(path + " error loading:" + str(err))

# region: domain helpers

static func bone_mask_(_bone_mask_: Array[int]) -> String:
	var first_b = _bone_mask_[0] if _bone_mask_.size() > 0 else -1
	var last_b = _bone_mask_[-1] if _bone_mask_.size() > 0 else -1
	return "boneMsk [%d-%d] (size %d)" % [first_b, last_b, _bone_mask_.size()]

## returns name from id (no lib)
static func anim(anim_id: String) -> String:
	var pos = anim_id.rfind("/")
	var _r = anim_id.substr(pos + 1) if pos != -1 else anim_id
	return pp.in_q(_r)

# endregion

# region: inner helpers

static func __recursive_dict(_dict_: Dictionary, indent: String = "", one_string: bool = false) -> String:
	var r = "" if one_string else "\n"
	var next_indent = "" if one_string else indent + "\t"
	
	for key_ in _dict_.keys():
		var value_ = _dict_[key_]
		var value_str: String
		
		if value_ is float:
			value_str = str(round_001(value_))
		elif value_ is Dictionary:
			value_str = __recursive_dict(value_, next_indent)
		else:
			value_str = in_q(str(value_)) # str() for safety
		
		r += next_indent + in_q(key_) + " : " + value_str
		r += " " if one_string else "\n"
	
	if not _dict_.is_empty():
		r = r.trim_suffix(",\n")
	
	r += indent
	return r

# endregion