@tool
@icon("res://-assets-/x_icons/red/comet-red.svg")
extends BaseArea3DCharacterSystem

## Weapon area which DAMAGES.
## HitBox registers collision with it and uses base_weapon for calculations
class_name WeaponHurtBox


## not nullable
## base_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info
var base_weapon: BaseWeapon

var _previous_position: Vector3
var _velocity: Vector3


func get_hard_dependencies() -> Array[Object]:
	return [
		base_weapon
	]

## used instead of _ready. Called from base weapon. 
## So base_weapon is guaranteed to be non nullable
func initialise() -> void:
	collision_layer = Collision.Layers.WEAPON_AREA
	collision_mask = Collision.Masks.WEAPON_AREA_MASK
	
	_previous_position = global_position

	if __validate_deps_set_init():
		body_entered.connect(_on_body_entered)
	else:
		__log_("init problems, body_entered sig not connected")


func _physics_process(delta: float) -> void:
	if __could_not_initialised():
		return
	# racks weapon _velocity
	_velocity = (global_position - _previous_position) / delta
	_previous_position = global_position


func is_player() -> bool:
	if __could_not_initialised():
		return false
	return base_weapon.is_player()

func pp_name():
	if __could_not_initialised():
		return pp.s("miserable not initted hurtbox, please help", "🔻 HurtBox")
	var character_name := "Pl" if is_player() else "E"
	return pp.s(character_name, base_weapon.pp_name(), "🔻 HurtBox")


# todo: what is this magic ...
func _get_weapon_push_force() -> int:
	if base_weapon.is_player():
		return 6
	else:
		return 25


func _on_body_entered(body: Node3D) -> void:
	if not base_weapon.is_attacking():
		return

	__log_(em.mark_x2, "going to resolve hit for body", body, body.name)
	# base_weapon.resolve_hit(body)
	
	if not body is RigidBody3D:
		return

	__log_(em.mark_x2, "detected rigid body and we r attacking", body, body.name)
	# push in direction weapon is moving
	var push_direction = _velocity.normalized()
	body.apply_central_impulse(push_direction * _get_weapon_push_force())


# alternative
# func _physics_process(_delta: float) -> void:
# 		var overlapping = get_overlapping_bodies()
# 		if not overlapping.is_empty():
# 			print("Overlapping bodies: ", overlapping)


## __LOGS


func __LOG_B():
	return LogToggler.HIT_HURT_BOX_B

func __LOG_INDENT() -> int:
	return 10
