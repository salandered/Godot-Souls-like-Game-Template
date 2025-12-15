@abstract
class_name BaseSignalContainer
extends RefCountedSystem


var sig_id_to_signal_data: Dictionary[String, SignalData]


func _init():
	var _signal_data_list: Array[SignalData] = _get_signal_data_list()

	if len(_signal_data_list) == 0:
		__log_warn("no _signal_data_list created; that is odd", "", "")
	else:
		__log_("init", "_signal_data_list created")
		for _signal_data: SignalData in _signal_data_list:
			__log_("init", _signal_data)

	sig_id_to_signal_data = {}
	for item: SignalData in _signal_data_list:
		if u.safe_has_no_key(sig_id_to_signal_data, item.signal_id):
			sig_id_to_signal_data[item.signal_id] = item


## called on init only
@abstract func _get_signal_data_list() -> Array[SignalData]


func get_by_sig_id(sig_id: String) -> SignalData:
	var _r: SignalData = u.safe_get_dict_key(sig_id_to_signal_data, sig_id, null)
	if not _r:
		__log_warn_soft("no SignalData found for sig_id", "", "", pp.in_q(sig_id))
	return _r


func has_signal_id(sig_id: String) -> bool:
	return sig_id_to_signal_data.has(sig_id)


## __LOG

func __LOG_B() -> bool:
	return LogToggler.SIG_C_B
