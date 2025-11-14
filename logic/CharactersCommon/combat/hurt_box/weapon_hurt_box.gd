@tool
@icon("res://-assets-/x_icons/red/comet-red.svg")
extends Area3D

## Weapon area which DAMAGES.
## HitBox registers collision with it and uses base_weapon for calculations
class_name WeaponHurtBox

## base_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info
var base_weapon: BaseWeapon


## used instead of _ready. Called from base weapon. 
## So base_weapon is guaranteed to be non nullable
func initialise() -> void:
	collision_layer = Collision.Layers.WEAPON_AREA
	collision_mask = Collision.Masks.WEAPON_AREA_MASK

	if not base_weapon.is_player():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	__log_(em.mark_x2, "detected body", body, body.name)
	pass
	# if body is BreakableStatic:
	# 	__log_("detected body with 'shatter' method", body, body.name)
	# 	body.shatter()


func get_my_weapon_name() -> String:
	var _weapon_name: String = ""
	if not base_weapon:
		_weapon_name = '<no weapon assigned' + em.warn + '>'
	else:
		_weapon_name = base_weapon.get_weapon_name()
	return _weapon_name


# alternative
# func _physics_process(_delta: float) -> void:
# 		var overlapping = get_overlapping_bodies()
# 		if not overlapping.is_empty():
# 			print("Overlapping bodies: ", overlapping)


## __LOGS

func __log_(...parts: Array):
	print_.hurt_box(pp.s(name, get_my_weapon_name()), pp.list_(parts))

func __log_warn(what: String, where: String, fallback: String, ...context: Array):
	print_.warn(false, what, pp.s("HurtBox", name, get_my_weapon_name(), where), fallback, pp.list_(context))
