class_name SignalData
extends RefCounted

## experimental wrapper. Not sure, most of the recent code works without it


## signal name from SignalID
var signal_id: String
var signal_obj: Signal


## payload: Dictionary[String, Variant]

## signal_id_ is the signal name from SignalID
func _init(signal_id_: String, signal_obj_: Signal):
	self.signal_id = signal_id_
	self.signal_obj = signal_obj_


func _to_string() -> String:
	var _msg_sig := pp.s("signal_obj name", signal_obj.get_name()) \
		if not signal_obj.is_null() \
		else "[invalid sig]"
	return pp.s("🌠sigId:", pp.in_q(signal_id), _msg_sig)


func connect_(callable: Callable):
	signal_obj.connect(callable)
