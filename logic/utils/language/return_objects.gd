class_name RO ## Return Object
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


class IntReturn extends _BaseReturn:
	var value: int

	func _init(err_: bool, value_: int = Const.BIG_MEANINGLESS_NUMBER_INT):
		super._init(err_)
		self.value = value_


class FloatReturn extends _BaseReturn:
	var value: float

	func _init(err_: bool, value_: float = Const.BIG_MEANINGLESS_NUMBER):
		super._init(err_)
		self.value = value_


class StringReturn extends _BaseReturn:
	var value: String

	func _init(err_: bool, value_: String = ""):
		super._init(err_)
		self.value = value_

class SNameReturn extends _BaseReturn:
	var value: StringName

	func _init(err_: bool, value_: StringName = Const.EMPTY_SNAME):
		super._init(err_)
		self.value = value_


class DictReturn extends _BaseReturn:
	var value: Dictionary

	func _init(err_: bool, value_: Dictionary):
		super._init(err_)
		self.value = value_


class Vector2iReturn extends _BaseReturn:
	var value: Vector2i

	func _init(err_: bool, value_: Vector2i = Vector2i.ZERO):
		super._init(err_)
		self.value = value_


class ColorReturn extends _BaseReturn:
	var value: Color

	func _init(err_: bool, value_: Color = Color.TRANSPARENT):
		super._init(err_)
		self.value = value_


class VariantReturn extends _BaseReturn:
	var value: Variant

	func _init(err_: bool, value_: Variant = null):
		super._init(err_)
		self.value = value_
