@tool
class_name HSMTimeSpentMetric
extends BaseTimeSpentMetric


@export var ts_curr_sbs_2: Label
@export var ts_curr_sbs_3: Label
@export var ts_curr_sbs_4: Label

var _character: BigGuyCharacter


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		ts_curr_sbs_2
	]


func _initialise_implementation() -> void:
	super._initialise_implementation()
	_update_metric(ts_curr_sbs_2, DEF_NO_VALUE)
	_update_metric(ts_curr_sbs_3, DEF_NO_VALUE)
	_update_metric(ts_curr_sbs_4, DEF_NO_VALUE)

	_char_type = DVS.CharacterType.HSM_ENEMY
	_character = Groups.get_first_phe_bg_by_group_with_tag(self , Const.DEMO_ENEMY_TAG)
	if not _character:
		__log_warn_soft("get_first_phe_bg_by_group returned null")


func get_character() -> BaseStaticCharacter:
	return _character
	

func _process_imp(delta: float):
	_update_metric_with_depth(ts_curr_sbs_2, 2)
	_update_metric_with_depth(ts_curr_sbs_3, 3)
	_update_metric_with_depth(ts_curr_sbs_4, 4)
		

func _update_metric_with_depth(label, depth):
	if not _character: return DEF_NO_VALUE
	var curr_sbs := _character.get_current_substate_by_depth(depth)
	if not curr_sbs: return DEF_NO_VALUE
	var ts := curr_sbs.get_actual_time_spent()
	
	_update_metric(label, ts)