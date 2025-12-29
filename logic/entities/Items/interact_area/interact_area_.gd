@tool
class_name InteractArea
extends Area3DSystem

@onready var label: Label3D = %InteractLabel
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


@export var label_text: String = "Press E to interact":
	set(value):
		label_text = value
		if is_node_ready(): _set_label_text()

@export var area_radius: float = 2.0:
	set(value):
		area_radius = value
		if is_node_ready(): _set_area_radius()

@export var label_y_offset: float = 0.7:
	set(value):
		label_y_offset = value
		if is_node_ready(): _set_label_y_offset()

@export var ENABLED: bool = true


signal SIG_interacted


func __hard_dependencies() -> Array[Object]:
	return [
		collision_shape_3d,
		collision_shape_3d.shape
	]

func __soft_dependencies() -> Array[Object]:
	return [
	]


var player_found = false


func _ready() -> void:
	collision_mask = Collision.Masks.ONLY_PLAYER
	if collision_shape_3d and collision_shape_3d.shape:
		collision_shape_3d.shape = collision_shape_3d.shape.duplicate()

	set_all_properties()
	
	if not Engine.is_editor_hint():
		label.visible = false
		visible = false
		set_process_unhandled_input(false)

	__validate_dependencies()


func set_all_properties():
	_set_label_text()
	_set_area_radius()
	_set_label_y_offset()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if __could_not_initialised():
		return


	var bodies := get_overlapping_bodies()
	find_player(bodies)

	
	set_label_visible(player_found and ENABLED)
	
	set_process_unhandled_input_(player_found)


func find_player(bodies: Array[Node3D]):
	for body in bodies:
		if body is Princess or body is FreeCameraBody:
			set_player_found(true)
			return
	set_player_found(false)


func set_player_found(value: bool):
	if player_found != value:
		__log_("set_player_found", "changed to", pp.in_q(value))
		player_found = value


func set_label_visible(value: bool):
	if label.visible != value:
		__log_("set_label_visible", "changed to", pp.in_q(value))
		label.visible = value
		visible = value


func set_process_unhandled_input_(value: bool):
	if is_processing_unhandled_input() != value:
		__log_("set_process_unhandled_input_", "changed to", pp.in_q(value))
		set_process_unhandled_input(value)


# region Export Setters

func _set_label_text() -> void:
	if label:
		label.text = label_text

func _set_area_radius() -> void:
	if not collision_shape_3d or not collision_shape_3d.shape or not collision_shape_3d.shape is SphereShape3D:
		return
	collision_shape_3d.shape.radius = area_radius

func _set_label_y_offset() -> void:
	if label:
		label.global_position.y = label_y_offset
# endregion


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.interact):
		if ENABLED:
			SIG_interacted.emit()
			# stops the event here so it doesn't trigger the floor/item below
			get_viewport().set_input_as_handled()
