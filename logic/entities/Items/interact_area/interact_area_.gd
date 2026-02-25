@tool
class_name InteractArea
extends CommonArea

@onready var label: Label3D = %InteractLabel
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


@export_group("Label")
@export var label_text: String = "Press E to interact":
	set(value):
		label_text = value
		if is_node_ready(): _set_label_text()


@export var label_y_offset: float = 0.7:
	set(value):
		label_y_offset = value
		if is_node_ready(): _set_label_y_offset()


signal SIG_interacted


var _is_player_inside := false


var cooldown_sig_emit := Cooldown.new(0.4)

var common_area_config := CommonAreaConfig.new(
		MonitorType.PROCESS_LIST,
		false,
		true,
		Collision.Masks.ONLY_PLAYER,
		true
	)

func _get_common_area_config() -> CommonAreaConfig:
	return common_area_config


func _get_coll_shape() -> CollisionShape3D:
	return collision_shape_3d


## _READY
# region

func _ready_implementation() -> void:
	_set_label_text()
	_set_label_y_offset()


func _ready_implementation_non_editor() -> void:
	_set_label_visible(false)
	set_process_unhandled_input(false)

# endregion


# MONITOR HANDLERS
# region 

var _player_found_this_frame := false

func on_overlapping_bodies(incoming_bodies: Array[Node3D]) -> void:
	_player_found_this_frame = false
	for body in incoming_bodies:
		if body is Princess or body is FreeCameraBody:
			_player_found_this_frame = true
			return
	_player_found_this_frame = false


# endregion

func _physics_process_implementation(delta: float) -> void:
	# __log_("_physics_process_implementation")
	_set_is_player_inside(_player_found_this_frame)

	_set_label_visible(_is_player_inside and MONITOR_ENABLED)
	
	_set_process_unhandled_input(_is_player_inside and MONITOR_ENABLED)


func _set_monitor_enable_implementation(value: bool):
	_set_label_visible(value)
	_set_process_unhandled_input(value)


func _set_is_player_inside(value: bool):
	if _is_player_inside != value:
		__log_("_set_is_player_inside", "changed to", pp.in_q(value))
		_is_player_inside = value


func _set_label_visible(value: bool):
	if label.visible != value:
		__log_("_set_label_visible", "changed to", pp.in_q(value))

		## -- all sets are atomic --
		label.visible = value
		visible = value # for safety explicit set


func _set_process_unhandled_input(value: bool):
	if is_processing_unhandled_input() != value:
		__log_("_set_process_unhandled_input", "changed to", pp.in_q(value))
		set_process_unhandled_input(value)


# region Export Setters

func _set_label_text() -> void:
	if label:
		label.text = label_text

func _set_label_y_offset() -> void:
	if label:
		label.global_position.y = global_position.y + label_y_offset
		
# endregion


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.interact):
		if _can_interact():
			SigUtils.safe_emit_no_payload(SIG_interacted)
			
			cooldown_sig_emit.mark_time()
			InputUtils.mark_input_handled(self )


func _can_interact() -> bool:
	if not MONITOR_ENABLED:
		return false
	if not _is_player_inside: # probably redundant at this point
		return false

	var current_time := TimeUtils.get_curr_time_ticks_sec()
	if not cooldown_sig_emit.is_cooldown_passed(true, pp_name()):
		return false
	
	return true


##


func __LOG_B() -> bool:
	return false
