extends RefCounted
class_name CollShapeTranform


## NOTE: consider duplication shape before calling 
## provide capsule size mult values
static func shrink_coll_shape_capsule_size(coll_shape: CollisionShape3D, radius_mult: float = 0.7, height_mult: float = 0.6) -> void:
	if not coll_shape.shape is CapsuleShape3D:
		__log_warn(false, "coll_shape.shape is not CapsuleShape3D; not supported", "shrink_coll_shape_capsule_size", "return")
		return
	var shape = coll_shape.shape as CapsuleShape3D
	var _orig_radius = shape.radius
	var _orig_height = shape.height
	shape.radius = _orig_radius * radius_mult
	shape.height = _orig_height * height_mult

	__log_("coll capsusle shape shrinked to",
		pp.list_([shape.radius, shape.height]),
		"from",
		pp.list_([_orig_radius, _orig_height]))


## NOTE: consider duplication shape before calling 
static func set_coll_shape_capsule_size(coll_shape: CollisionShape3D, rad: float, height: float) -> void:
	if not coll_shape.shape is CapsuleShape3D:
		__log_warn(false, "coll_shape.shape is not CapsuleShape3D; not supported", "set_coll_shape_capsule_size", "return")
		return
	var shape = coll_shape.shape as CapsuleShape3D

	__log_("set coll caps shape to values",
		pp.list_([rad, height]),
		"from",
		pp.list_([shape.radius, shape.height]))

	shape.radius = rad
	shape.height = height

# region: __LOGS


static var LOG_B: bool = false

static func __log_(...parts: Array):
	if LOG_B: print_.prefix("CollShapeTranform", pp.list_(parts))

static func __log_warn(crucial: bool, what: String, where: String, fallback: String, ...details: Array):
	print_.warn(crucial, what, pp.s(where, "CollShapeTranform"), fallback, pp.list_(details))

# endregion