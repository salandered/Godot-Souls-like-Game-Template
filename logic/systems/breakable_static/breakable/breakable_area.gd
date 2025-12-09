@abstract
class_name BreakableArea
extends BaseArea3DSystem


## external event
## should be emitted in on_area_entered
signal SIG_breaking_area_entered


func _ready() -> void:
	collision_layer = Collision.Layers.PROP_COL
	collision_mask = Collision.Layers.WEAPON_AREA | Collision.Layers.HITBOX_AREA
	area_entered.connect(on_area_entered)
	monitoring = true


func get_SIG_breaking_area_entered() -> Signal:
	return SIG_breaking_area_entered


@abstract func on_area_entered(incoming_area: Area3D) -> void
