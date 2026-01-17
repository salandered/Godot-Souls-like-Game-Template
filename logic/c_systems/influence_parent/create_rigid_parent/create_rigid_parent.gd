extends Node3DSystem


@export var fire_only_once: bool = false
## CAUTIOUS
@export var delete_mesh_instance: bool = false
@export_category("Rigid body settings")
@export var use_geometry_center_for_mass: bool = false


@onready var monitor_pl_enter_sig_area: MonitorPlayerEnterSignalArea = $MonitorPlEnterSigArea


func __hard_dependencies() -> Array[Object]:
	return [
		monitor_pl_enter_sig_area
	]

func __hard_validation() -> bool:
	if not monitor_pl_enter_sig_area is MonitorPlayerEnterSignalArea:
		return false
	if not _find_mesh():
		return false
	return true


func _find_mesh() -> MeshInstance3D:
	var parent := get_parent()
	if not parent or not parent is MeshInstance3D:
		return null
	return parent

func _find_static_grand_parent() -> StaticBody3D:
	var mesh := _find_mesh()
	if not mesh:
		return null
	var grand_parent := mesh.get_parent()
	if not grand_parent or not grand_parent is StaticBody3D:
		return null
	return grand_parent


var mesh_instance: MeshInstance3D
var static_grand_parent: StaticBody3D


func _ready() -> void:
	mesh_instance = _find_mesh()
	static_grand_parent = _find_static_grand_parent()
	if __perform_validation():
		monitor_pl_enter_sig_area.fire_only_once = fire_only_once
		monitor_pl_enter_sig_area.SIG_player_entered.connect(on_player_entered)


func _shut_down():
	if monitor_pl_enter_sig_area.SIG_player_entered.is_connected(on_player_entered):
		monitor_pl_enter_sig_area.SIG_player_entered.disconnect(on_player_entered)


func on_player_entered(incoming_body: Node3D):
	if mesh_instance and mesh_instance is MeshInstance3D and not mesh_instance.is_queued_for_deletion():
		RigidBodyUtils.fully_create_rigid_body_from_mesh_instance(self, mesh_instance, use_geometry_center_for_mass)
		if delete_mesh_instance:
			if static_grand_parent:
				static_grand_parent.queue_free()
			else:
				mesh_instance.queue_free()
		if fire_only_once:
			_shut_down()

## temp
func on_lever():
	on_player_entered(null)


func __LOG_B() -> bool:
	return false
