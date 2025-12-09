class_name SignalData
extends RefCounted

## signal name from SignalName
var signal_id: String
var signal_obj: Signal

## signal_id_ is the signal name from SignalName
func _init(signal_id_: String, signal_obj_: Signal):
	self.signal_id = signal_id_
	self.signal_obj = signal_obj_


func _to_string() -> String:
	return pp.s("sigId:", signal_id, "sigObjname/id:", signal_obj.get_name(), signal_obj.get_object_id())