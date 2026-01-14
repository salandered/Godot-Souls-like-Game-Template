class_name CommonAreaConfig
extends RefCountedLogger


var monitor_type: CommonArea.MonitorType
var interact_with_areas: bool
var interact_with_bodies: bool
var coll_mask: Collision.Masks
var duplicate_coll_shape: bool


func _init(
	monitor_type_: CommonArea.MonitorType = CommonArea.MonitorType.PROCESS,
	interact_with_areas_: bool = false,
	interact_with_bodies_: bool = false,
	coll_mask_: Collision.Masks = Collision.Masks._ZERO_MASK,
	duplicate_coll_shape_: bool = true
) -> void:
	self.interact_with_areas = interact_with_areas_
	self.interact_with_bodies = interact_with_bodies_
	self.coll_mask = coll_mask_
	self.monitor_type = monitor_type_
	self.duplicate_coll_shape = duplicate_coll_shape_

	# hard_validation()
	# soft_validation()


## CommonAreaConfig treats hard validation as a soft one. 
## Call hard validation in CommonArea if needed.
func hard_validation() -> bool:
	var _r := true
	var _reason := ""
	# if CommonArea.MonitorType.get(monitor_type) == null:
	if monitor_type not in [CommonArea.MonitorType.PROCESS, CommonArea.MonitorType.PROCESS_LIST, CommonArea.MonitorType.SIGNAL]:
		_r = false
		_reason += pp.s("monitor_type is invalid:", pp.in_q(monitor_type))

	if _r == false:
		__log_warn_soft("hard_validation not ok", "", "", "reason", _reason)
	return _r


func soft_validation() -> bool:
	var _r := true
	var _reason := ""
	if interact_with_areas == false and interact_with_bodies == false:
		_r = false
		_reason += pp.s("both interact_with_areas and interact_with_bodies are false, it is weird")
	
	if coll_mask == Collision.Masks._ZERO_MASK:
		_r = false
		_reason += pp.s("coll_mask is ZERO_MASK, it is weird")

	if _r == false:
		__log_warn_soft("soft_validation not ok", "", "", "reason", _reason)
	return _r