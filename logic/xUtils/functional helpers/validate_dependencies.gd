extends RefCountedStaticLogger
class_name ValidateDependencies


const __initialised_NAME = "__initialised"
const __get_hard_dependencies_NAME = "get_hard_dependencies"
const __get_soft_dependencies_NAME = "get_soft_dependencies"


## returns True if __initialised was set to True
## returns False if was not set or in case of any problem
static func validate_deps_and_set_init_true(for_whom: Object) -> bool:
	var _r := validate_dependencies(for_whom)
	_r = set_initialised_true(for_whom, _r)
	return _r


## NOTE: returns true if only hard deps were met
static func validate_dependencies(for_whom: Object) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false

	var hard_dependencies_are_ok := validate_hard_deps(for_whom)
	validate_soft_deps(for_whom)
	
	return hard_dependencies_are_ok


## returns True if __initialised was set to True
## returns False if was not set or in case of any problem
static func set_initialised_true(for_whom: Object, hard_deps_are_ok: bool = false) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false


	if hard_deps_are_ok or validate_hard_deps(for_whom):
		if u.safe_has_property(for_whom, __initialised_NAME):
			for_whom.set(__initialised_NAME, true)
			return true
		else:
			__log_(pp.s(_pp_for_whom(for_whom), "Node has dependencies met but missing", pp.in_q(__initialised_NAME), "property"))
			return false
	else:
		__log_(pp.s(_pp_for_whom(for_whom), "Refused to set", pp.in_q(__initialised_NAME), "Hard dependencies not met"))
		if u.safe_has_property(for_whom, __initialised_NAME):
			for_whom.set(__initialised_NAME, false) # just in case
			
		return false


static func validate_hard_deps(for_whom: Object) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false
	var _hard_list: Array[Object] = []
	if u.safe_has_method(for_whom, __get_hard_dependencies_NAME):
		var raw_result = for_whom.get_hard_dependencies()
		if raw_result and raw_result is Array:
			_hard_list = TypeCast.array_of_objects(raw_result, true)
	var hard_dependencies_are_ok := _validate_hard_deps(for_whom, _hard_list)
	return hard_dependencies_are_ok


static func validate_soft_deps(for_whom: Object) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false
	var _soft_list: Array[Object] = []
	if u.safe_has_method(for_whom, __get_soft_dependencies_NAME):
		var raw_result = for_whom.get_soft_dependencies()
		if raw_result and raw_result is Array:
			_soft_list = TypeCast.array_of_objects(raw_result, true)

	var soft_dependencies_are_ok := _validate_soft_deps(for_whom, _soft_list)
	return soft_dependencies_are_ok


static func _validate_hard_deps(for_whom: Object, list_: Array[Object]) -> bool:
	var _r: bool = true
	var _missing_count := 0
	
	for item in list_:
		if not u.is_object_ok(item, "item in hard deps list"):
			_missing_count += 1
			_r = false
	
	if not _r:
		__log_error(pp.s(_pp_for_whom(for_whom), "Missing", _missing_count, "Hard Deps"))
		
	return _r


static func _validate_soft_deps(for_whom: Object, list_: Array[Object]) -> bool:
	var _r: bool = true
	var _missing_count := 0
	
	for item in list_:
		if not u.is_object_ok(item, "item in soft deps list"):
			_missing_count += 1
			_r = false

	if not _r:
		__log_warn(pp.s(_pp_for_whom(for_whom), "Missing", _missing_count, "Soft Deps"))
		
	return _r


static func _pp_for_whom(for_whom: Object) -> String:
	return u.safe_object_pp_name(for_whom)


# region: __LOGS


static func pp_name() -> String:
	return "ValidateDependencies"

static func __LOG_B() -> bool:
	return false

static func __LOG_INDENT() -> int:
	return 10

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion