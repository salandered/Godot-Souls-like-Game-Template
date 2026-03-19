class_name pp
extends RefCounted


const CLN := ":"
const SCLN := ";"
const ARROW := "->"
const ANGLE := "∠"
const EMPTY := ""
const HYPTHEN := "-"
const S_X := "x"
const SPLIT := "|"

const TAB := "\t"
const TAB_X2 := "\t\t"

const on_ent := "on-entr↪"
const on_ext := "on-exit↩"
const on_upd := "upd"
const on_internal_upd := "_upd"


## todo: research if creating packed array and then joining it is faster
static func s(...parts: Array) -> String:
	var r := ""
	for part in parts:
		if part is float:
			r += str(pp.round_001(part))
		elif part is Vector3:
			r += pp.vec3(part)
		elif part is Vector2:
			r += pp.vec2(part)
		else:
			r += str(part)
		r += " "
	return r


static func s_in_q(...parts: Array) -> String:
	var edited_parts: Array = []
	var even: bool = true
	for part in parts:
		if even:
			edited_parts.append(part)
		else:
			edited_parts.append(pp.in_q(part))
		even = not even
	return list_(edited_parts)


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
	var r := rad_to_deg(a.normalized().angle_to(b.normalized()))
	r = snapped(r, 0.00001)
	if to_str:
		return str(r)
	return r


static func srad2deg(angle_: float, add_symbol: bool = true) -> String:
	var r := str(frad2deg(angle_))
	if add_symbol:
		return r + "°"
	return r

static func frad2deg(angle_: float) -> float:
	var r := rad_to_deg(angle_)
	r = snapped(r, 0.01)
	return r


# region:  basic structures

static func vec3(v: Vector3) -> String:
	return "(%3.3f %3.3f %3.3f)" % [v.x, v.y, v.z]


static func vec2(v: Vector2) -> String:
	return "(%4.2f %4.2f)" % [v.x, v.y]


static func dict_flat_perfomant(_dict_: Dictionary, max_length: int = 600) -> String:
	if _dict_.is_empty():
		return "{}"

	var parts := PackedStringArray()
	parts.resize(_dict_.size())
	var idx := 0

	for key in _dict_:
		var value = _dict_[key]
		var value_str: String
		
		if value is float:
			value_str = str(round_001(value))
		elif value is Dictionary:
			value_str = "<Dict>"
		else:
			value_str = in_q(str(value))
		
		parts[idx] = key + " : " + value_str
		idx += 1
	
	return StrUtils.cut_string(" ".join(parts), max_length)


static func dict_(_dict_: Dictionary, json: bool = false, one_string: bool = false, one_level: bool = false, max_length = 600) -> String:
	if json:
		return JSON.stringify(_dict_, "\t")
	if _dict_.is_empty():
		return "{}"
	var r := __recursive_dict(_dict_, "", one_string, one_level)
	return StrUtils.cut_string(r, max_length)


static func list_(parts: Array, json: bool = false, max_length = 800) -> String:
	if json:
		return JSON.stringify(parts, "\t")
	if parts.size() == 0:
		return "[-x-]"
	var r := ""
	for part in parts:
		if part is float:
			r += pp.round_001(part) + " "
		elif part is Vector2:
			r += pp.vec2(part) + " "
		elif part is Vector3:
			r += pp.vec3(part) + " "
		elif part is Array:
			r += pp.array_(part) + " "
		else:
			r += str(part) + " "
	r = StrUtils.cut_string(r, max_length)
	return r


static func array_(parts: Array, json: bool = false) -> String:
	var r := list_(parts, json, 300)
	return pp.in_br(r)

# endregion


# region: domain helpers

static func bone_mask_(_bone_mask_: Array[int]) -> String:
	var first_b := _bone_mask_[0] if _bone_mask_.size() > 0 else -1
	var last_b := _bone_mask_[-1] if _bone_mask_.size() > 0 else -1
	return "boneMsk [%d-%d] (size %d)" % [first_b, last_b, _bone_mask_.size()]

## returns name from id (no lib)
static func anim_n(anim_id: StringName, no_q: bool = false) -> String:
	var anim_name := StrUtils.get_last_slash_part(anim_id)
	return anim_name if no_q else pp.in_q(anim_name)


static func sig_data(signal_data: SignalData, signal_payload: Dictionary[StringName, Variant]) -> String:
	if not signal_data: return ""
	return pp.s(signal_data, "with payload", pp.dict_(signal_payload, false, false, true))

static func sig(signal_: Signal, signal_payload: Dictionary[StringName, Variant]) -> String:
	return pp.s(signal_, "with payload", pp.dict_(signal_payload, false, false, true))

static func bus_id(bus_id_: StringName) -> String:
	return pp.s("bus🎧", pp.in_q(bus_id_))

static func asp_3d_play(asp: AudioStreamPlayer3D) -> String:
	if not asp: return ""
	return pp.s("vol/pitch", pp.round_01(asp.volume_db), "/", pp.round_01(asp.pitch_scale),
		"stream", pp.in_q(asp.stream.resource_name) if asp.stream else "[-]")

static func asp_play(asp: AudioStreamPlayer) -> String:
	if not asp: return ""
	return pp.s("vol/pitch", pp.round_01(asp.volume_db), "/", pp.round_01(asp.pitch_scale),
		"stream", pp.in_q(asp.stream.resource_name) if asp.stream else "[-]")

# endregion


# region: inner helpers

static func __recursive_dict(_dict_: Dictionary, indent: String = "", one_string: bool = false, one_level: bool = false) -> String:
	var r := "" if one_string else "\n"
	var next_indent := "" if one_string else indent + "\t"
	
	for key_ in _dict_.keys():
		var value_: Variant = _dict_[key_]
		var value_str: String
		
		if value_ is float:
			value_str = str(round_001(value_))
		elif value_ is Dictionary:
			if one_level:
				value_str = "<Dict>"
			else:
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


## fmt for metrics labels
static func metric_fmt(v: Variant, fmt_show_vector_len: bool = true) -> String:
	match typeof(v):
		TYPE_VECTOR2:
			# format: (x, y) [len]
			var _r := "(%4.1f %4.1f)" % [v.x, v.y]
			_r += " [%4.1f]" % v.length() if fmt_show_vector_len else ""
			return _r
		TYPE_VECTOR3:
			var _r := "(%4.1f %4.1f %4.1f)" % [v.x, v.y, v.z]
			_r += " [%4.1f]" % v.length() if fmt_show_vector_len else ""
			return _r
		TYPE_FLOAT:
			return "%5.2f" % v
		TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY:
			if v.is_empty(): return "[]"
			return str(v)
		_:
			return str(v)


static func file_load_err(err, path: String):
	if err == OK:
		print_.dev("file_load_err", path, " loaded successfully")
	elif err == ERR_DOES_NOT_EXIST:
		print_.dev("file_load_err", path, " no file found")
	else:
		print_.dev("file_load_err", path, " error loading:", str(err))