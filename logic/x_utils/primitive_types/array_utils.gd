class_name ArrayUtils
extends RefCounted


static func get_only_one_or_null(array_: Array[Variant], allow_long_arrays: bool = true, wl: StringName = WL.PUSH_WARN) -> Variant:
	if error_.empty_list(array_, "get_only_one_or_null", wl):
		return null
	if allow_long_arrays:
		return array_[0]
	if not error_.one_len_list(array_, "get_only_one_or_null", wl):
		return null
	else:
		return array_[0]
