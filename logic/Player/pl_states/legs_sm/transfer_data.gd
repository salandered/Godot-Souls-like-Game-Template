extends RefCounted

class_name TranferData


var action_name: String
var _transfer: Dictionary


func _get_by_key(key: String) -> Variant:
	return u.safe_get_dict_key(_transfer, key, "Getting _transfer from TranferData💼")


## optional return
func get_by_action_and_key(action_name_: String, key: String) -> Variant:
	if action_name == action_name_:
		var value: Variant = _get_by_key(key)
		# __log_value(action_name_, key, value)
		return value
	# print_.psm("TransferData💼", pp.s("⚠️⚠️: action mismatch, will return null. Set/requested:", action_name, action_name_))
	return null


func get_by_action(action_name_: String) -> Variant:
	if action_name == action_name_:
		return _transfer
	return null


func fill(action_name_: String, data_: Dictionary):
	var _msg := pp.s(pp._dict(data_) if data_ is Dictionary else "| data is not a Dict ⚠️⚠️")
	# print_.psm("TransferData💼", "fill for " + pp.in_q(action_name_) + ":\t" + _msg)
	action_name = action_name_
	_transfer = data_.duplicate_deep()


func _reset():
	action_name = ""
	_transfer = {}


func __log_value(action_name_, key, value):
	var _v_msg := ""
	if value is Dictionary:
		_v_msg = pp._dict(value)
	elif value == null:
		_v_msg = "no key or its value is null ⚠️"
	else:
		_v_msg = str(value)
	var _msg := pp.s("get_by_action_and_key", pp.in_q(action_name_), pp.in_q(key), _v_msg)
	print_.psm("TransferData💼", _msg)
