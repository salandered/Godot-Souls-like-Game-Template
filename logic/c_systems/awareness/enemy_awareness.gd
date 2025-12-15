@tool
@icon("res://-assets-/x_icons/yellow/icon_visibility.png")
extends Node3DCharacterSystem
class_name EnemyAwareness


@export var sight_mask: int = Collision.Layers.ENVIRONMENT_COL | Collision.Layers.PLAYER_COL

var me: BaseEnemyCharacter

## expects downcast as a child
@onready var downcast = $Downcast as RayCast3D

@export var debug_sight_cone: bool = true


func is_player() -> bool:
	return false


func initialise() -> void:
	dev_initialise()


func detect_player() -> Detection:
	var seen := can_see_player()
	var heard := can_hear_player()
	var dist := me.global_position.distance_to(me.player.global_position)
	return Detection.new(seen, heard, dist)


func can_see_player() -> bool:
	var player := me.player
	var own_pos := me.global_position
	var target_pos := player.global_position
	var to_player := target_pos - own_pos
	# cheap distance check
	if to_player.length() > me.sight_distance:
		return false
	# FOV check
	if not _is_in_sight_cone(target_pos):
		return false
	# obstacle check
	var eye_pos := own_pos + Vector3.UP * 1.5
	var player_eye := target_pos + Vector3.UP * 1.0
	if _is_sight_blocked(eye_pos, player_eye):
		return false
	return true


func can_hear_player() -> bool:
	# TODO: add calm attribute of player states
	return me.global_position.distance_squared_to(me.player.global_position) <= u.fpow2(me.hearing_distance)


func get_floor_distance() -> float:
	if downcast.is_colliding():
		return downcast.global_position.distance_to(downcast.get_collision_point())
	return 999999


func _is_in_sight_cone(target_position: Vector3) -> bool:
	var forward := me.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	var to_target := target_position - me.global_position
	to_target.y = 0
	to_target = to_target.normalized()
	var half_fov := deg_to_rad(me.sight_angle_degrees * 0.5)
	return forward.dot(to_target) >= cos(half_fov)


func _is_sight_blocked(from_pos: Vector3, to_pos: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.new()
	query.from = from_pos
	query.to = to_pos
	query.exclude = [me]
	query.collision_mask = sight_mask
	# now perform the raycast with a single-argument call
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit:
		return false
	return hit.collider != me.player


## DEV
# region

var sight_cone_visual: MeshInstance3D
var conus_color := Color(1, 0.5, 1, 0.25)


func dev_initialise() -> void:
	if not OS.is_debug_build():
		return
	if debug_sight_cone:
		_create_sight_cone_visual()


func _create_sight_cone_visual():
	sight_cone_visual = MeshInstance3D.new()
	add_child(sight_cone_visual)
	sight_cone_visual.position = Vector3.UP * 1.5
	sight_cone_visual.material_override = _make_sight_material()
	_update_sight_cone_mesh()


func _make_sight_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = conus_color
	mat.flags_transparent = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _update_sight_cone_mesh():
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_angle := deg_to_rad(me.sight_angle_degrees * 0.5)
	var segments := 24.0
	for i in range(segments):
		var a1 := lerpf(-half_angle, half_angle, float(i) / segments)
		var a2 := lerpf(-half_angle, half_angle, float(i + 1) / segments)
		var p1 = Vector3(sin(a1), 0, cos(a1)) * me.sight_distance # interface violation ....
		var p2 = Vector3(sin(a2), 0, cos(a2)) * me.sight_distance
		mesh.surface_add_vertex(Vector3.ZERO)
		mesh.surface_add_vertex(p1)
		mesh.surface_add_vertex(p2)
	mesh.surface_end()
	sight_cone_visual.mesh = mesh

# endregion


## LOG


func __LOG_INDENT() -> int:
	return 0

func __LOG_B() -> bool:
	return LogToggler.AWARENESS_B
