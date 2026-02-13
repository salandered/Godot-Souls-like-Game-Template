extends RayCast3D
class_name DownCast

@export var attachment: Node3D

@export var __log_dist: bool = false

@export_group("Debug Visuals")
@export var __show_visuals: bool = false
@export var dv_color_hit: Color = Color.DARK_GREEN
@export var dv_color_miss: Color = Color.RED
@export var thickness: float = 0.07

var _head: MeshInstance3D
var _tail: MeshInstance3D
var _shaft: MeshInstance3D


## TROUBLESHOOTING: 
##  - attachment should be bone like Hips or Root and correctly identified
##  - after changing Skeleton, bone attachments could bug without reassigning their bones.
##  - for 'Debug Shape' Debug visual options should be checked
##  - if attachment is Root, it should be a bit higher than that.


func _ready() -> void:
	collision_mask = Collision.Layers.ENVIRONMENT_COL


	set_visuals_enabled(false)
	SigUtils.safe_connect_pairs([
			[GlobalUIInfo.SIG_dvc_bvalue_changed, _on_SIG_dvc_bvalue_changed],
		])


func _process(delta: float) -> void:
	if attachment:
		global_position = attachment.global_position
			
	if __log_dist: print_.prefix("Downcast dist", pp.s(global_position.distance_to(get_collision_point())))

	_process_dv_visuals()


func _process_dv_visuals() -> void:
	if not __show_visuals:
		return

	if not _head:
		_head = MeshInstanceUtils.create_simple_sphere(thickness, dv_color_miss)
		add_child(_head)
		_head.top_level = true
		
		_tail = MeshInstanceUtils.create_simple_sphere(thickness, dv_color_miss)
		add_child(_tail)
		_tail.top_level = true
		
		_shaft = MeshInstanceUtils.create_generic_cylinder(thickness * 0.3)
		add_child(_shaft)
		_shaft.top_level = true

	var start: Vector3 = global_position
	var end: Vector3
	var is_hit: bool = is_colliding()
	var current_color: Color = dv_color_hit if is_hit else dv_color_miss

	if is_hit:
		end = get_collision_point()
	else:
		end = to_global(target_position)

	_safe_update_color(_head, current_color)
	_safe_update_color(_tail, current_color)

	_head.global_position = start
	_tail.global_position = end
	
	_head.visible = true
	_tail.visible = true

	MeshInstanceUtils.place_cylinder_between(_shaft, start, end, current_color)


func _safe_update_color(mesh: MeshInstance3D, color: Color) -> void:
	if not mesh:
		return
		
	var mat := mesh.material_override as StandardMaterial3D
	if mat:
		mat.albedo_color = color


func set_visuals_enabled(value: bool):
	__show_visuals = value
	if _head: _head.visible = value
	if _tail: _tail.visible = value
	if _shaft: _shaft.visible = value


func _on_SIG_dvc_bvalue_changed(payload: Dictionary[String, Variant]):
	var _r := DVCSIGPayloadParser.safe_bget_value_by_dvc_key(payload, DVS.KeyBValueChanger.DOWNCAST)
	if _r.err:
		return

	set_visuals_enabled(_r.value)
