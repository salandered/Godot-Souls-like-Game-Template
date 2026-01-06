@tool
@icon("res://-assets-/x_icons/red/comet-red.svg")
extends Area3DSystem

## Weapon area which DAMAGES.
## HitBox registers collision with it and uses my_weapon for calculations
class_name WeaponHurtBox


## not nullable
## my_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info
var my_weapon: BaseWeapon

var _previous_position: Vector3
var _velocity: Vector3 = Vector3.ZERO
var sig_container: BaseWeaponSignalContainer


## using sig_id+body ID as a key
var _sig_throttler: EventThrottler
var _overlapping_obj_throttler: EventThrottler

func __hard_dependencies() -> Array[Object]:
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
	_overlapping_obj_throttler = EventThrottler.new(0.4, 2.0, 3.0, "OverlapObjThrottler" + em.dagger + "HurtB")

	# todo: add validation: must have a CollisionShape3D
	if __perform_validation():
		pass
	else:
		__log_warn_soft("init problems, body_entered wont be triggered, all disabled")
		set_physics_process(false)
		

func _physics_process(delta: float) -> void:
	_velocity = (global_position - _previous_position) / delta
	_previous_position = global_position

	if has_overlapping_areas():
		for area in get_overlapping_areas():
			_on_body_or_area_entered(area)

	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			_on_body_or_area_entered(body)


## not nullable
func _get_my_weapon() -> BaseWeapon:
	return my_weapon


func pp_name():
	var _char_name := ""
	if _get_my_weapon():
		_char_name = "Pl" if _get_my_weapon().is_player() else "E"
	return pp.s(_char_name, _get_my_weapon().pp_name(), "🔻 HurtBox")


# todo: what is this magic ...
func _get_weapon_push_force() -> int:
	var _r := 6
	if _get_my_weapon():
		if _get_my_weapon().is_player():
			_r = 6 if _get_my_weapon().get_weapon_id() != WeaponID.small_pinga_blade else 18
		else:
			_r = 25
	return _r


func _on_body_or_area_entered(body: Node3D) -> void:
	if not _get_my_weapon().is_attacking():
		return

	if _is_mine_hit_box(body):
		return


	var body_id := body.get_instance_id()
	if _overlapping_obj_throttler.is_throttled(body_id):
		return
		
	_overlapping_obj_throttler.record_event(body_id)
	# __log_(em.mark_x2, "Hit | body", body.name, u.safe_object_pp_name(body))

	_apply_sfx_hit_to_my_weapon(body)
	_apply_sparks_to_my_weapon(body)

	_apply_sfx_hit_target(body)

	_apply_push(body)
	

func _apply_sfx_hit_to_my_weapon(body: Node3D):
	_emit_sig(SignalID.sfx_hit_weapon, {}, body)

const SPARK_HIT = preload("uid://fohkachkfkuq")


func _apply_sparks_to_my_weapon(body: Node3D):
	if not my_weapon.spark_marker or not SPARK_HIT:
		return
	
	var hit_position := my_weapon.spark_marker.global_position
	var hit_normal := -_velocity.normalized()
	
	var sparks: SparksHit = SPARK_HIT.instantiate()
	get_tree().root.add_child(sparks)
	sparks.set_direction(hit_normal)
	sparks.set_from_config(my_weapon.get_spark_config())
	sparks.global_position = hit_position
	

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
	if body is BaseRigidBodyPhysicsSFX: # will manage on its own
		return
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

	# __log_(em.mark_x2, "detected rigid body and we r attacking", body, body.name)
	# push in direction weapon is moving
	var push_direction = _velocity.normalized()

	body.apply_central_impulse(push_direction * _get_weapon_push_force())


func _emit_sig(sig_id: String, payload: Dictionary[String, Variant], body: Node3D) -> void:
	var key := sig_id + "_" + str(body.get_instance_id())
	if not _sig_throttler.is_throttled(key):
		var _sig_data := sig_container.get_by_sig_id(sig_id)
		u.safe_emit(_sig_data, payload, false)
		_sig_throttler.record_event(key)


func _is_mine_hit_box(body: Node3D) -> bool:
	if body is not CharacterHitbox:
		return false
	var casted = body as CharacterHitbox
	if not casted.get_combat():
		return false
	if not _get_my_weapon().get_holder():
		return false
	if casted.get_combat().get_character() == _get_my_weapon().get_holder():
		return true
	return false


## __LOGS


func __LOG_B():
	return true

func __LOG_INDENT() -> int:
	return 10
