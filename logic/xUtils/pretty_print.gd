extends RefCounted
class_name pp


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
