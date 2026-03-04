@tool
@icon("res://-assets-/x_icons/red/hit_box_3d.svg")
extends Area3DCharacterSystem
## Area which CAN BE damaged. Opposed to an area which DAMAGES.
class_name CharacterHitbox

## TODO: use CommonArea framework

## Docs
# region
##  - MUST have '_combat' assigned
## 
##  - Character can have any number of hitboxes. 
##    Hitbox takes HitData from incoming weapon and passes to BaseCombat
##    BaseCombat processes any HitData instance only once using unique ID.
##    => as long as weapon has the same HitData while contacting with hitboxes, the hit will be processed just once
##    
##  - Multiple registers on contacting same CharacterHitbox with the same HurtBox is prevented
##    by 'add_hitbox_to_contact_list' logic. It stores contacted hitbox on a weapon side.
##    It also means that u can have any number of hurt boxes on a weapon.
##    Technically the mechanic of processing any hitbox only once at BaseCombat side makes 'contact_list' less important
##    But the weapon knowing what it hits and other character's BaseCombat knowing what hits were applied 
##    are two separate bounded contexts (like, player and an enemy)
##    So it cleaner this way. Also faster.
# endregion
##
## Hitbox shape conventions (NOTE)
# region:
## - Supports ONLY one coll shape CollisionShape 
## - Supports ONLY CapsuleShape as a shape (Shape3D) of this coll shape (CollisionShape)
## - CapsuleShape is auto DUPLICATED. This prevents accidental changing several shapes while working with one hitbox.
# endregion
##
## About _physics_process implementation
# region: 
## Used to be 'area_entered.connect(on_area_contact)'
## but signal won't be fired if colliders are already inside one another. 
## If the weapon is inside a hit box when attack started, it won't register. 
## So we switched to _physics_process.
## Consider other approaches in case of perf issues...
# endregion


var _combat: BaseCombat

## guaranteed one in shape of CapsuleShape3D. can't be zero and not supported several. 
var _my_coll_shapes: Array[CollisionShape3D]
var _original_capsule_shape_radius: float
var _original_capsule_shape_height: float


## Weapon contact signal settings
const my_area_field = "my_area_field"
const incoming_area_field = "incoming_area_field"
const in_contact_list_field = "in_contact_list_field"
var emit_on_attacking_wp: bool = false
var emit_on_attacking_wp_every_frame: bool = false
signal SIG_incoming_weapon_contacted(payload: Dictionary[StringName, Variant])


func __hard_dependencies() -> Array:
	return [
		_combat
	]


func __hard_validation() -> bool:
	var _r := true
	var _msg := ""

	if len(_my_coll_shapes) == 0:
		_msg = pp.s("len of _my_coll_shapes is Zero", "Not supported!")
		_r = false

	var original_shape := _my_coll_shapes[0].shape
	if original_shape == null:
		_msg = pp.s("CollisionShape3D has no shape")
		_r = false

	if not original_shape is CapsuleShape3D:
		_msg = pp.s("shape is not CapsuleShape3D. Not supported")
		_r = false

	if not _r:
		__log_error(_msg)

	return _r


func initialize(combat_: BaseCombat) -> void:
	self._combat = combat_
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Masks.HITBOX_AREA_MASK
	
	_my_coll_shapes = get_descendants.collision_shapes(self )

	if len(_my_coll_shapes) > 1:
		__log_warn_soft(pp.s("len of _my_coll_shapes > 1", "Not supported! will be working only with the first one"))

	if __perform_validation():
		# duplicate to avoid shared resource issues
		var original_shape := _my_coll_shapes[0].shape
		_my_coll_shapes[0].shape = original_shape.duplicate()

		var shape := _my_coll_shapes[0].shape as CapsuleShape3D # hard validated
		__log_("Duplicated capsule shape used in CollisionShape " + shape.resource_name)

		_original_capsule_shape_radius = shape.radius
		_original_capsule_shape_height = shape.height
		__log_("--- CharacterHitbox ready ---")
	else:
		__log_warn_soft("CharacterHitbox init problems, not going to work")
		set_physics_process(false)


## not nullable
func get_combat() -> BaseCombat:
	return _combat


func _physics_process(delta: float) -> void:
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			on_area_contact(area)


func is_player() -> bool:
	if get_combat():
		return get_combat().is_player()
	else:
		return false


# region: SHAPE LOGIC

## not nullable
func _get_collision_shape() -> CollisionShape3D:
	return _my_coll_shapes[0]


## provide capsule size mult values
func shrink_hitbox(radius_mult: float = 0.7, height_mult: float = 0.6):
	if not __validation_ok(): return
	var coll_shape := _get_collision_shape()
	CollShapeUtils.shrink_coll_shape_capsule_size(coll_shape, radius_mult, height_mult)


func restore_hitbox():
	if not __validation_ok(): return
	var coll_shape := _get_collision_shape()
	CollShapeUtils.set_coll_shape_capsule_size(coll_shape, _original_capsule_shape_radius, _original_capsule_shape_height)

# endregion


func on_area_contact(incoming_area: Node3D):
	if not incoming_area is WeaponHurtBox:
		return

	var _weapon_area := incoming_area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area._my_weapon
	if not weapon:
		__log_error("weapon is null", "on_area_contact", "return")
		return

	if _is_weapon_mine(weapon):
		return
	
	if __LOG_B(): __log_extra("contact after _is_weapon_mine", incoming_area, weapon)
	if not weapon.is_attacking():
		return


	if __LOG_B(): __log_extra("contact after weapon.is_attacking():", incoming_area, weapon)


	## NOTE: adding to contact list only after other checks
	if weapon.is_in_contact_hitbox_list(self ):
		if emit_on_attacking_wp and emit_on_attacking_wp_every_frame:
			_emit_SIG_incoming_area_contacted(_weapon_area, true)
		return
	weapon.add_hitbox_to_contact_list(self )

	if emit_on_attacking_wp:
		_emit_SIG_incoming_area_contacted(_weapon_area, false)


	if __LOG_B(): __log_("on_area_contact", pp.s("Contact with weapon", pp.in_q(weapon.get_weapon_id()), "by", pp.in_q(weapon.get_holder().pp_name())))

	var hit_data := weapon.get_hit_data()
	if not hit_data:
		__log_error("weapon hit data is null", "on_area_contact", "return")
		return

	if __LOG_B(): __log_("Calling apply_hit with hit data", hit_data)
	_combat.apply_hit(hit_data)


func _is_weapon_mine(weapon: BaseWeapon) -> bool:
	if weapon.get_holder() == _combat.get_character():
		return true
	return false

##

func _emit_SIG_incoming_area_contacted(incoming_area: Area3D, in_contact_list: bool):
	SigUtils.safe_emit(SIG_incoming_weapon_contacted, {
		my_area_field: self ,
		incoming_area_field: incoming_area,
		in_contact_list_field: in_contact_list
		})


## LOGS
# region


func pp_name():
	var character_name := "Pl" if is_player() else "E"
	return pp.s(character_name, "💢HitBox")


func _to_string() -> String:
	return pp.s(pp_name(), get_instance_id())

	
var __EXTRA_LOG_B: bool = false


func __log_extra(...parts: Array):
	if __EXTRA_LOG_B:
		__log_(pp.list_(parts))


func __LOG_B():
	return LogToggler.HIT_HURT_BOX_B

func __LOG_INDENT() -> int:
	return 10

# endregion
