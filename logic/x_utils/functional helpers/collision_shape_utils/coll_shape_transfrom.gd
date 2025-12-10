extends RefCountedStaticLogger
class_name CollShapeTranform

## NOTE: consider duplication shape before calling 
## provide capsule size mult values
static func shrink_coll_shape_capsule_size(coll_shape: CollisionShape3D, radius_mult: float = 0.7, height_mult: float = 0.6) -> void:
	if not coll_shape.shape is CapsuleShape3D:
		__log_error("coll_shape.shape is not CapsuleShape3D; not supported", "shrink_coll_shape_capsule_size", "return")
		return
	var shape: CapsuleShape3D = coll_shape.shape
	var _orig_radius := shape.radius
	var _orig_height := shape.height
	shape.radius = _orig_radius * radius_mult
	shape.height = _orig_height * height_mult

	__log_("coll capsusle shape shrinked to",
		pp.array_([shape.radius, shape.height]),
		"from",
		pp.array_([_orig_radius, _orig_height]))


## NOTE: consider duplication shape before calling 
static func set_coll_shape_capsule_size(coll_shape: CollisionShape3D, rad: float, height: float) -> void:
	if not coll_shape.shape is CapsuleShape3D:
		__log_error("coll_shape.shape is not CapsuleShape3D; not supported", "set_coll_shape_capsule_size", "return")
		return
	var shape: CapsuleShape3D = coll_shape.shape

	__log_("set coll caps shape to values",
		pp.array_([rad, height]),
		"from",
		pp.array_([shape.radius, shape.height]))

	shape.radius = rad
	shape.height = height


# region: __LOGS


static func pp_name() -> String:
	return "CollShapeTranform"

static func __LOG_B() -> bool:
	return false

static func __LOG_INDENT() -> int:
	return 10

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion
