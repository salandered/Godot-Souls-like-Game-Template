extends RefCountedStaticLogger
class_name ValidateDependencies

## as much logic as possible move here, so all the extenders (like NodeSystem) don't have duplicated logic.

const __initialised_NAME = "__initialised"
const __hard_dependencies_NAME = "__hard_dependencies"
const __soft_dependencies_NAME = "__soft_dependencies"
const __hard_validate_NAME = "__hard_validate"
const __soft_validate_NAME = "__soft_validate"


## returns True if __initialised was set to True
## returns False if was not set or in case of any other problem
## NOTE: returns True if only soft validation failed
static func validate_and_set_init_flag(for_whom: Object) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false

	var _r: bool = false
	var hard_validation_is_ok := _perform_hard_validation(for_whom)
	_perform_soft_validation(for_whom)
	_r = _set_initialised_flag(for_whom, hard_validation_is_ok)
	return _r


static func _set_initialised_flag(for_whom: Object, hard_deps_are_ok: bool) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false
	
	if u.safe_has_property(for_whom, __initialised_NAME):
		for_whom.set(__initialised_NAME, hard_deps_are_ok)
		return hard_deps_are_ok
	
	## no __initialised_NAME flag, which should not happen
	if hard_deps_are_ok:
		__log_(pp.s(_pp_for_whom(for_whom), "Validation succeeded but missing flag", pp.in_q(__initialised_NAME)))
		return false
	else:
		__log_(pp.s(_pp_for_whom(for_whom), "Validation failed and also missing flag", pp.in_q(__initialised_NAME)))
		return false


static func _perform_hard_validation(for_whom: Object) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false
	var _hard_list: Array[Object] = []
	if u.safe_has_method(for_whom, __hard_dependencies_NAME):
		var raw_result = for_whom.__hard_dependencies()
		if raw_result and raw_result is Array:
			_hard_list = TypeCast.array_of_objects(raw_result, true)
	var hard_list_is_ok := _validate_deps_list(for_whom, _hard_list, "hard")

	var _hard_valid_is_ok: bool = true
	if u.safe_has_method(for_whom, __hard_validate_NAME):
		var raw_result = for_whom.__hard_validate()
		if raw_result and raw_result is bool:
			_hard_valid_is_ok = raw_result

	return hard_list_is_ok and _hard_valid_is_ok


static func _perform_soft_validation(for_whom: Object) -> bool:
	if not u.is_object_ok(for_whom, "for_whom"): return false
	var _soft_list: Array[Object] = []
	if u.safe_has_method(for_whom, __soft_dependencies_NAME):
		var raw_result = for_whom.__soft_dependencies()
		if raw_result and raw_result is Array:
			_soft_list = TypeCast.array_of_objects(raw_result, true)
	var soft_list_is_ok := _validate_deps_list(for_whom, _soft_list, "soft")

	var _soft_valid_is_ok: bool = true
	if u.safe_has_method(for_whom, __soft_validate_NAME):
		var raw_result = for_whom.__soft_validate()
		if raw_result and raw_result is bool:
			_soft_valid_is_ok = raw_result
			
	return soft_list_is_ok and _soft_valid_is_ok


static func _validate_deps_list(for_whom: Object, list_: Array[Object], context: String) -> bool:
	var _r: bool = true
	var _missing_count := 0
	var counter := 0
	
	for item in list_:
		if not u.is_object_ok(item, pp.s("item #", pp.in_sq(counter), "in", context, "deps list")):
			_missing_count += 1
			_r = false
		counter += 1
	
	if not _r:
		__log_error(pp.s(_pp_for_whom(for_whom), "Missing amount of", _missing_count, context, "deps"))
		
	return _r


static func _pp_for_whom(for_whom: Object) -> String:
	return u.safe_object_pp_name(for_whom)


# region: __LOGS


static func pp_name() -> String:
	return "🔌ValidateDependencies"

static func __LOG_B() -> bool:
	return false


static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion