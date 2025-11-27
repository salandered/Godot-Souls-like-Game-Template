@tool
@icon("res://-assets-/x_icons/red/comet-red.svg")
extends Area3D

## Weapon area which DAMAGES.
## HitBox registers collision with it and uses base_weapon for calculations
class_name WeaponHurtBox


## not nullable
## base_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info
var base_weapon: BaseWeapon

var _previous_position: Vector3
var _velocity: Vector3

## used instead of _ready. Called from base weapon. 
## So base_weapon is guaranteed to be non nullable
func initialise() -> void:
	collision_layer = Collision.Layers.WEAPON_AREA
	collision_mask = Collision.Masks.WEAPON_AREA_MASK
	
	_previous_position = global_position
	body_entered.connect(_on_body_entered)
	assert(base_weapon)


func _physics_process(delta):
	# racks weapon _velocity
	_velocity = (global_position - _previous_position) / delta
	_previous_position = global_position

func _get_weapon_push_force() -> int:
	if base_weapon.is_player():
		return 6
	else:
		return 25


func _on_body_entered(body: Node3D) -> void:
	if not body is RigidBody3D:
		return

	if not base_weapon.is_attacking():
		return

	__log_(em.mark_x2, "detected rigid body and we r attacking", body, body.name)
	# push in direction weapon is moving
	var push_direction = _velocity.normalized()
	body.apply_central_impulse(push_direction * _get_weapon_push_force())


func get_my_weapon_name() -> String:
	return base_weapon.get_weapon_name()


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
