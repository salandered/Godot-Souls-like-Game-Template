class_name ArrayUtils
extends RefCounted


static func get_only_one_or_null(array_: Array[Variant], warn_level: String = WL.PUSH_WARN) -> Variant:
	if not error_.len_one(array_, "get_only_one_or_null", warn_level):
		return array_[0]
	return null