@tool
class_name InputActionsGridManager
extends BaseMetricsGridManager


var _monitored_move_actions: Array[StringName] = []
var _monitored_attack_actions: Array[StringName] = []
var _monitored_other_actions: Array[StringName] = []


func get_dtc_op_key() -> DTS.KeyBOverlayPanel:
	return DTS.KeyBOverlayPanel.ACTION_INPUT


func initialize_implementation() -> void:
	super.initialize_implementation()

	var all_actions: Array[StringName] = InputMap.get_actions()
	
	for action in all_actions:
		if action.begins_with("ui_"): continue
		if action.begins_with("dev_"): continue
		if action.begins_with("DEV_"): continue

		if "move_" in action:
			_monitored_move_actions.append(action)
		elif "attack" in action:
			_monitored_attack_actions.append(action)
		else:
			_monitored_other_actions.append(action)
		
	_monitored_move_actions.sort()
	_monitored_attack_actions.sort()
	_monitored_other_actions.sort()

	__log_("_ready", "Monitoring len move/attack/other",
			_monitored_move_actions.size(),
			_monitored_attack_actions.size(),
			_monitored_other_actions.size()
			)
	

func _process_implementation(delta: float) -> void:
	_update_action_metrics()


func _update_action_metrics() -> void:
	_update_category("Movement", _monitored_move_actions)
	_update_category("Attack", _monitored_attack_actions)
	_update_category("All Other", _monitored_other_actions)


func _update_category(metric_name: String, _monitored_actions: Array[StringName]):
	var active_actions: Array[StringName] = []
	
	for action in _monitored_actions:
		if Input.is_action_pressed(action):
			active_actions.append(action)
	
	var pp_str := " ".join(active_actions)
	
	_metrics_grid.update_metric(metric_name, pp_str)
