@abstract
class_name BreakableArea
extends Area3DSystem


## external event
## should be emitted in on_area_entered
signal _SIG_breaking_area_entered


func _ready() -> void:
	collision_layer = Collision.Layers.PROP_COL
	collision_mask = Collision.Layers.WEAPON_AREA | Collision.Layers.HITBOX_AREA
	# area_entered.connect(on_area_entered)
	monitoring = true


func _physics_process(delta: float) -> void:
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			on_area_entered(area)


func get_SIG_breaking_area_entered() -> Signal:
	return _SIG_breaking_area_entered


@abstract func on_area_entered(incoming_area: Area3D) -> void
