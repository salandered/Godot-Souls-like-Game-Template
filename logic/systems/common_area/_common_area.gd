@tool

@abstract
class_name CommonArea
extends Area3DSystem


## if false: - if monitor_type PROCESS, _physics_process is muted
##			 - if monitor_type SIGNAL, signal handlers are not called
## set here initial value. It can be changed on the run.
@export var MONITOR_ENABLED: bool = true


@export_group("Collision")
## used only if coll_shape_type is SPHERE
@export var area_sphere_radius: float = 2.0:
	set(value):
		area_sphere_radius = value
		if is_node_ready(): _set_area_sphere_radius()
## used only if coll_shape_type is CAPSULE
@export var area_capsule_radius: float = 0.5:
	set(value):
		area_capsule_radius = value
		if is_node_ready(): _set_area_capsule_size()
## used only if coll_shape_type is CAPSULE
@export var area_capsule_height: float = 2.0:
	set(value):
		area_capsule_height = value
		if is_node_ready(): _set_area_capsule_size()

enum MonitorType {
	## uses built in signals like area_entered to call handlers like on_area_entered
	SIGNAL,
	## uses built in funcions like get_overlapping_areas inside _physics_process.
	## still calls on_area_entered for any object in a list. 
	## It is easy to switch between SIGNAL and PROCESS during the development.
	PROCESS,
	## same as PROCESS but lets implementation to work with a list of overlapping objects 
	## coming from functions like get_overlapping_areas.
	## calls functions like on_overlapping_areas(Area3D[]) [in contrast with on_area_entered(Area3D)]
	PROCESS_LIST
}


func __hard_dependencies() -> Array:
	return [
		_get_coll_shape(),
	]

func __soft_dependencies() -> Array:
	return [
	]

func __hard_validation() -> bool:
	if not _get_coll_shape() or not _get_coll_shape().shape:
		return false

	if not _get_common_area_config().hard_validation():
		return false

	return true

## CONFIG

@abstract func _get_common_area_config() -> CommonAreaConfig

##

## _READY
# region

func _ready() -> void:
	_ready_can_run_in_editor()

	if not eu.is_editor():
		_ready_non_editor()
	
	
	if not __perform_validation():
		if not eu.is_editor(): # also muted in editor
			__log_warn_soft("won't be working")
			_shut_down()


func _ready_can_run_in_editor():
	if _is_duplicate_coll_shape():
		if _get_coll_shape() and _get_coll_shape().shape:
			_get_coll_shape().shape = _get_coll_shape().shape.duplicate()

	_set_export_properties()

	_ready_implementation()

			
func _ready_non_editor():
	collision_layer = Collision.Layers.DEBRIS_COL
	collision_mask = _get_common_area_config().coll_mask

	var _monitor_type := _get_common_area_config().monitor_type
	match _monitor_type:
		MonitorType.SIGNAL:
			if _get_common_area_config().interact_with_areas:
				area_entered.connect(__on_area_entered)
			if _get_common_area_config().interact_with_bodies:
				body_entered.connect(__on_body_entered)
			set_physics_process(false)
		MonitorType.PROCESS, MonitorType.PROCESS_LIST:
			set_physics_process(true)
		_:
			__log_error("unknown or unhandled monitor_type")


	_ready_implementation_non_editor()


func _shut_down():
	SigUtils.safe_disconnect_pairs([
			[area_entered, __on_area_entered],
			[body_entered, __on_body_entered]
		]
	)
	set_physics_process(false)
	visible = false
	set_process_unhandled_input(false) # just in case, whether implementation used or not


func _set_export_properties():
	_set_area_sphere_radius()
	_set_area_capsule_size()


@abstract func _get_coll_shape() -> CollisionShape3D

## if true, changing shape for instantiated scene won't change it for all others
## usually this is what we want
func _is_duplicate_coll_shape() -> bool:
	return true


## last thing to run in _ready_can_run_in_editor, just before the _ready_non_editor
@abstract func _ready_implementation() -> void

## last thing to run in _ready_non_editor, just before the validation framework
@abstract func _ready_implementation_non_editor() -> void

# endregion


func _physics_process(delta: float) -> void:
	if eu.is_editor():
		return

	if not MONITOR_ENABLED:
		return

	var _monitor_type := _get_common_area_config().monitor_type

	if _get_common_area_config().interact_with_areas:
		var _overlapping_areas: Array[Area3D] = get_overlapping_areas()
		match _monitor_type:
			MonitorType.PROCESS:
				for area in _overlapping_areas:
					on_area_entered(area)
			MonitorType.PROCESS_LIST:
				on_overlapping_areas(_overlapping_areas)
			

	if _get_common_area_config().interact_with_bodies:
		var _overlapping_bodies: Array[Node3D] = get_overlapping_bodies()

		match _monitor_type:
			MonitorType.PROCESS:
				for body in _overlapping_bodies:
					on_body_entered(body)
			MonitorType.PROCESS_LIST:
				on_overlapping_bodies(_overlapping_bodies)

	_physics_process_implementation(delta)


## run at the end of _physics_process, which means it runs after functions
##    like on_area_entered, on_overlapping_areas, etc
## implement as pass if not used
@abstract func _physics_process_implementation(delta: float) -> void

# PUBLIC API
# region


func set_monitor_enable(value: bool):
	__log_("set_monitor_enable", value, "from", MONITOR_ENABLED)
	MONITOR_ENABLED = value
	set_physics_process(value)
	_set_monitor_enable_implementation(value)

## can be overridden
func _set_monitor_enable_implementation(value: bool) -> void:
	pass

# endregion

# MONITOR HANDLERS
# region 

## should not be overridden. use on_area_entered
func __on_area_entered(incoming_area: Area3D) -> void:
	if MONITOR_ENABLED:
		on_area_entered(incoming_area)

## should not be overridden. use on_body_entered
func __on_body_entered(incoming_body: Node3D) -> void:
	if MONITOR_ENABLED:
		on_body_entered(incoming_body)


## to override
func on_area_entered(incoming_area: Area3D) -> void:
	if _get_common_area_config().monitor_type in [MonitorType.SIGNAL, MonitorType.PROCESS] and _get_common_area_config().interact_with_areas:
		__log_warn(_handler_warn_msg, "", "", "implement on_area_entered")

## to override
func on_body_entered(incoming_body: Node3D) -> void:
	if _get_common_area_config().monitor_type in [MonitorType.SIGNAL, MonitorType.PROCESS] and _get_common_area_config().interact_with_bodies:
		__log_warn(_handler_warn_msg, "", "", "implement on_body_entered")

## to override
func on_overlapping_areas(incoming_areas: Array[Area3D]) -> void:
	if _get_common_area_config().monitor_type in [MonitorType.PROCESS_LIST] and _get_common_area_config().interact_with_areas:
		__log_warn(_handler_warn_msg, "", "", "implement on_overlapping_areas")

## to override
func on_overlapping_bodies(incoming_bodies: Array[Node3D]) -> void:
	if _get_common_area_config().monitor_type in [MonitorType.PROCESS_LIST] and _get_common_area_config().interact_with_bodies:
		__log_warn(_handler_warn_msg, "", "", "implement on_overlapping_bodies")

var _handler_warn_msg := "handler which is required for area to function is not implemented"

# endregion


# region Export Setters

func _set_area_sphere_radius() -> void:
	if not _get_coll_shape() or not _get_coll_shape().shape or not _get_coll_shape().shape is SphereShape3D:
		return
	_get_coll_shape().shape.radius = area_sphere_radius


func _set_area_capsule_size() -> void:
	if not _get_coll_shape() or not _get_coll_shape().shape or not _get_coll_shape().shape is CapsuleShape3D:
		__log_("_set_area_capsule_size can not set")
		return
	__log_("_set_area_capsule_size", area_capsule_radius, area_capsule_height)
	_get_coll_shape().shape.radius = area_capsule_radius
	_get_coll_shape().shape.height = area_capsule_height

# endregion


func __LOG_B() -> bool:
	return false
