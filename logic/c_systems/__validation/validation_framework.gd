extends RefCountedStaticLogger
class_name ValidationFramework

## DOCS
# region
## As much logic as possible moved here, so all the extenders (like NodeSystem) don't have duplicated code.
## NOTE: using highlight extension for colorizing validation methods in recommended. 
## 	  See .vscode/settings.json
##    Example:
		# "(__hard_validation)": {
		# 	"filterLanguageRegex": "gdscript",
		# 	"decorations": [
		# 		{
		# 			"color": "#78e2a1d7",
		# 			"fontWeight": "bold",
		# 		},
		# 	]
		# },
# endregion


const __validated_NAME = "__validated"
const __hard_dependencies_NAME = "__hard_dependencies"
const __soft_dependencies_NAME = "__soft_dependencies"
const __hard_validation_NAME = "__hard_validation"
const __soft_validation_NAME = "__soft_validation"


## returns True if __validated was set to True
## returns False if was not set or in case of any other problem
## NOTE: returns True if only soft validation failed
static func validate_and_set_flag(for_whom: Object, process_disable_on_fail: bool = false) -> bool:
	if not ObjUtils.is_object_ok(for_whom, "for_whom"): return false

	var hard_validation_is_ok := _perform_hard_validation(for_whom)
	_perform_soft_validation(for_whom)
	_set_validated_flag(for_whom, hard_validation_is_ok)

	_process_disable(for_whom, process_disable_on_fail, hard_validation_is_ok)

	return hard_validation_is_ok


static func _set_validated_flag(for_whom: Object, hard_deps_are_ok: bool) -> bool:
	if not ObjUtils.is_object_ok(for_whom, "for_whom"): return false
	
	if ObjUtils.safe_has_property(for_whom, __validated_NAME):
		for_whom.set(__validated_NAME, hard_deps_are_ok)
		return hard_deps_are_ok
	
	## no __validated_NAME flag, which should not happen
	if hard_deps_are_ok:
		__log_warn_soft(_pp_for_whom(for_whom), "Validation succeeded but missing flag", pp.in_q(__validated_NAME))
		return false
	else:
		__log_warn_soft(_pp_for_whom(for_whom), "Validation failed and also missing flag", pp.in_q(__validated_NAME))
		return false


static func _perform_hard_validation(for_whom: Object) -> bool:
	if not ObjUtils.is_object_ok(for_whom, "for_whom"): return false
	var _hard_list: Array[Object] = []
	if ObjUtils.safe_has_method(for_whom, __hard_dependencies_NAME):
		var raw_result = for_whom.__hard_dependencies()
		if raw_result and raw_result is Array:
			_hard_list = TypeCast.array_of_objects(raw_result, true)
	var hard_list_is_ok := _validate_deps_list(for_whom, _hard_list, "hard")

	var _hard_valid_is_ok: bool = true
	if ObjUtils.safe_has_method(for_whom, __hard_validation_NAME):
		var raw_result = for_whom.__hard_validation()
		if raw_result and raw_result is bool:
			_hard_valid_is_ok = raw_result

	return hard_list_is_ok and _hard_valid_is_ok


static func _perform_soft_validation(for_whom: Object) -> bool:
	if not ObjUtils.is_object_ok(for_whom, "for_whom"): return false
	var _soft_list: Array[Object] = []
	if ObjUtils.safe_has_method(for_whom, __soft_dependencies_NAME):
		var raw_result = for_whom.__soft_dependencies()
		if raw_result and raw_result is Array:
			_soft_list = TypeCast.array_of_objects(raw_result, true)
	var soft_list_is_ok := _validate_deps_list(for_whom, _soft_list, "soft")

	var _soft_valid_is_ok: bool = true
	if ObjUtils.safe_has_method(for_whom, __soft_validation_NAME):
		var raw_result = for_whom.__soft_validation()
		if raw_result and raw_result is bool:
			_soft_valid_is_ok = raw_result
			
	return soft_list_is_ok and _soft_valid_is_ok


static func _validate_deps_list(for_whom: Object, list_: Array[Object], context: String) -> bool:
	var _r: bool = true
	var _missing_count := 0
	var counter := 0
	
	for item in list_:
		if not ObjUtils.is_object_ok(item, pp.s("item #", pp.in_sq(counter), "in", context, "deps list")):
			_missing_count += 1
			_r = false
		counter += 1
	
	if not _r:
		__log_error(pp.s(_pp_for_whom(for_whom), "Missing amount of", _missing_count, context, "deps"))
		
	return _r


static func _process_disable(for_whom: Object, process_disable_on_fail: bool, _is_valid: bool):
	if process_disable_on_fail and not _is_valid:
		if for_whom is Node:
			for_whom.process_mode = Node.PROCESS_MODE_DISABLED
			__log_warn_soft(_pp_for_whom(for_whom), "Validation failed => process mode set to DISABLED ✴️")
		else:
			__log_warn_soft(_pp_for_whom(for_whom),
				"Validation failed but cannot apply 'process_disable_on_fail' param: Object is not a Node.")


static func _pp_for_whom(for_whom: Object) -> String:
	return ObjUtils.safe_object_pp_name(for_whom)


# region: __LOGS


static func pp_name() -> String:
	return "__ValidationFramework__"


static func __LOG_B() -> bool:
	return false


static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion
