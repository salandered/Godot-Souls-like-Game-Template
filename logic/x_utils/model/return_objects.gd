class_name ReturnObject
extends RefCounted


class _BaseReturn:
	var err: bool

	func _init(err_: bool):
		self.err = err_


class BoolReturn extends _BaseReturn:
	var value: bool

	func _init(err_: bool, value_: bool = false):
		super._init(err_)
		self.value = value_


class FloatReturn extends _BaseReturn:
	var value: float

	func _init(err_: bool, value_: float = Constants.BIG_MEANINGLESS_NUMBER):
		super._init(err_)
		self.value = value_


class StringReturn extends _BaseReturn:
	var value: String

	func _init(err_: bool, value_: String = ""):
		super._init(err_)
		self.value = value_


class DictReturn extends _BaseReturn:
	var value: Dictionary

	func _init(err_: bool, value_: Dictionary):
		super._init(err_)
		self.value = value_


class VariantReturn extends _BaseReturn:
	var value: Variant

	func _init(err_: bool, value_: Variant = null):
		super._init(err_)
		self.value = value_