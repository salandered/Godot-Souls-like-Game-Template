@tool
@icon("res://-assets-/x_icons/red/comet-red.svg")
extends BaseArea3DCharacterSystem

## Weapon area which DAMAGES.
## HitBox registers collision with it and uses my_weapon for calculations
class_name WeaponHurtBox


## not nullable
## my_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info
var my_weapon: BaseWeapon

var _previous_position: Vector3
var _velocity: Vector3
var sig_container: BaseWeaponSignalContainer


## using sig_id+body ID as a key
var _sig_throttler: EventThrottler

func get_hard_dependencies() -> Array[Object]:
	return [
		my_weapon
	]


## used instead of _ready. Called from base weapon. 
## So my_weapon is guaranteed to be non nullable
func initialise(my_weapon_: BaseWeapon, sig_container_: BaseWeaponSignalContainer) -> void:
	self.my_weapon = my_weapon_
	self.sig_container = sig_container_

	collision_layer = Collision.Layers.WEAPON_AREA
	collision_mask = Collision.Masks.WEAPON_AREA_MASK
	
	_previous_position = global_position

	_sig_throttler = EventThrottler.new(0.4, 2.0, 3.0, "SFXSig" + em.dagger + "HurtB")

	if __validate_deps_set_init():
		body_entered.connect(_on_body_or_area_entered)
		area_entered.connect(_on_body_or_area_entered)
	else:
		__log_warn_soft("init problems, body_entered sig not connected")


func _physics_process(delta: float) -> void:
	if __could_not_initialised():
		return
	# racks weapon _velocity
	_velocity = (global_position - _previous_position) / delta
	_previous_position = global_position


func _get_my_weapon() -> BaseWeapon:
	return my_weapon


func is_player() -> bool:
	return _get_my_weapon().is_player()


func pp_name():
	var _char_name := "Pl" if is_player() else "E"
	return pp.s(_char_name, _get_my_weapon().pp_name(), "🔻 HurtBox")


# todo: what is this magic ...
func _get_weapon_push_force() -> int:
	if is_player():
		return 6
	else:
		return 25


func _on_body_or_area_entered(body: Node3D) -> void:
	if not _get_my_weapon().is_attacking():
		return

	
	__log_(em.mark_x2, "Hit | body", body, body.name, u.safe_object_pp_name(body))

	_apply_sfx_hit_to_my_weapon(body)

	_apply_sfx_hit_target(body)

	_apply_push(body)
	

func _apply_sfx_hit_to_my_weapon(body: Node3D):
	_emit_sig(SignalID.sfx_hit_weapon, {}, body)


func _apply_sfx_hit_target(body: Node3D):
	## AREA3D
	if body is BreakableArea:
		_emit_sig(SignalID.sfx_hit_target, {}, body)
		return
	if body is Area3D: # including CharacterHitbox (will manage on its own)
		return

	## CHARACTERBODY
	if body is CharacterBody3D:
		return
	
	## RIGID
	if body is RigidBody3D:
		_emit_sig(SignalID.sfx_hit_target, {}, body)
		return

	## STATIC
	if body is StaticBody3D:
		__log_(em.mark_x2, "Static", body, body.name, u.safe_object_pp_name(body))
		return


func _apply_push(body: Node3D):
	if not body is RigidBody3D:
		return

	__log_(em.mark_x2, "detected rigid body and we r attacking", body, body.name)
	# push in direction weapon is moving
	var push_direction = _velocity.normalized()

	body.apply_central_impulse(push_direction * _get_weapon_push_force())


func _emit_sig(sig_id: String, payload: Dictionary[String, Variant], body: Node3D) -> void:
	var key := sig_id + "_" + str(body.get_instance_id())
	if not _sig_throttler.is_throttled(key):
		u.safe_emit(sig_container.get_by_sig_id(sig_id), payload)
		_sig_throttler.record_event(key)

# alternative
# func _physics_process(_delta: float) -> void:
# 		var overlapping = get_overlapping_bodies()
# 		if not overlapping.is_empty():
# 			print("Overlapping bodies: ", overlapping)


## __LOGS


func __LOG_B():
	return true

func __LOG_INDENT() -> int:
	return 10
