class_name SigUtils
extends RefCounted


class BaseReturn:
	var err: bool

	func _init(err_: bool):
		self.err = err_

class BoolReturn extends BaseReturn:
	var value: bool

	func _init(err_: bool, value_: bool = false):
		super._init(err_)
		self.value = value_

class FloatReturn extends BaseReturn:
	var value: float

	func _init(err_: bool, value_: float = Constants.BIG_MEANINGLESS_NUMBER):
		super._init(err_)
		self.value = value_

class VariantReturn extends BaseReturn:
	var value: Variant

	func _init(err_: bool, value_: Variant = null):
		super._init(err_)
		self.value = value_


static func create_payload(key: String, value: Variant) -> Dictionary[String, Variant]:
	var d: Dictionary[String, Variant] = {key: value}
	return d

## returns value as a float
static func safe_get_int_float_payload_value(payload: Dictionary[String, Variant], payload_key: String) -> FloatReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false)
	if payload_value_return.err:
		return FloatReturn.new(true)
		
	var payload_value = payload_value_return.value

	if not (payload_value is float or payload_value is int):
		return FloatReturn.new(true)

	return FloatReturn.new(false, float(payload_value))


static func safe_get_bool_payload_value(payload: Dictionary[String, Variant], payload_key: String) -> BoolReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false)
	if payload_value_return.err:
		return BoolReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is bool):
		return BoolReturn.new(true)

	return BoolReturn.new(false, payload_value)


static func _get_value_by_key(payload: Dictionary[String, Variant], payload_key: String, null_allowed: bool = true) -> VariantReturn:
	if not u.safe_has_key(payload, payload_key, WL.SILENT):
		return VariantReturn.new(true)

	var payload_value = payload[payload_key]

	if not null_allowed and payload_value == null:
		return VariantReturn.new(true)

	return VariantReturn.new(false, payload_value)