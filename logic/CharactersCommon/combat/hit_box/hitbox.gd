@tool
@icon("res://-assets-/x_icons/red/hit_box_3d.svg")
extends Area3D

## Area which CAN BE damaged. Opposed to an area which DAMAGES.
class_name CharacterHitbox

## Docs
##  - MUST have 'combat' assigned
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


@export var combat: BaseCombat


## guaranteed one in shape of CapsuleShape3D. can't be zero and not supported several. 
var _my_coll_shapes: Array[CollisionShape3D]
var _original_capsule_shape_radius: float
var _original_capsule_shape_height: float


func _ready() -> void:
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Masks.HITBOX_AREA_MASK
	
	assert(combat, "Set combat system!")

	_my_coll_shapes = get_descendants.collision_shapes(self)
	if len(_my_coll_shapes) != 1:
		var msg = pp.s("len of _my_coll_shapes != 1", "Not supported!!", "len:", len(_my_coll_shapes))
		assert(false, msg)

	var original_shape = _my_coll_shapes[0].shape
	assert(original_shape != null, "CollisionShape3D has no shape!")
	assert(original_shape is CapsuleShape3D, "shape is not CapsuleShape3D. Not supported")
	
	# Duplicate to avoid shared resource issues
	_my_coll_shapes[0].shape = original_shape.duplicate()
	var shape := _my_coll_shapes[0].shape as CapsuleShape3D
	print_.hit_box(name, "Duplicated capsule shape used in CollisionShape! " + shape.resource_name)

	_original_capsule_shape_radius = shape.radius
	_original_capsule_shape_height = shape.height

	print_.hit_box(name, "--- CharacterHitbox ready ---")


func _physics_process(delta):
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			on_area_contact(area)


# region: shape logic


func get_collision_shape() -> CollisionShape3D:
	return _my_coll_shapes[0]


## provide capsule size mult values
func shrink_hitbox(radius_mult: float = 0.7, height_mult: float = 0.6):
	var coll_shape := get_collision_shape()
	var shape = coll_shape.shape as CapsuleShape3D
	shape.radius = _original_capsule_shape_radius * radius_mult
	shape.height = _original_capsule_shape_height * height_mult
	__log_("coll capsusle shape shrinked to",
		pp.list_([shape.radius, shape.height]),
		"from",
		pp.list_([_original_capsule_shape_radius, _original_capsule_shape_height]))


func restore_hitbox():
	var coll_shape := get_collision_shape()
	var shape = coll_shape.shape as CapsuleShape3D

	__log_("coll caps shape restored to orig values",
		pp.list_([_original_capsule_shape_radius, _original_capsule_shape_height]),
		"from",
		pp.list_([shape.radius, shape.height]))

	shape.radius = _original_capsule_shape_radius
	shape.height = _original_capsule_shape_height

# endregion

func is_player() -> bool:
	return combat.is_player()


func on_area_contact(incoming_area: Node3D):
	if not incoming_area is WeaponHurtBox:
		return

	# prints("contact", incoming_area, incoming_area.name, incoming_area.get_class())
	var _weapon_area := incoming_area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area.base_weapon
	if not weapon:
		__log_warn("weapon is null", "on_area_contact", "return")
		return

	if _is_weapon_mine(weapon):
		return

	
	__log_extra("contact after _is_weapon_mine", incoming_area, weapon)
	if not weapon.is_attacking():
		# if combat is PlayerCombat:
		# 	print_.prefix_s("contact", incoming_area, incoming_area.name, incoming_area.get_class())
		# __log_extra("Not attacking")
		return

	__log_extra("contact after weapon.is_attacking():", incoming_area, weapon)

	## NOTE: adding to contact list only after other checks
	if weapon.is_in_contact_hitbox_list(self):
		__log_("is_in_contact_hitbox_list true", weapon._contact_hitbox_list, self)
		return
	weapon.add_hitbox_to_contact_list(self)

	__log_("on_area_contact", pp.s("Contact with weapon", pp.in_q(weapon._weapon_name), "by", pp.in_q(weapon.holder.name)))

	var hit_data := weapon.get_hit_data()
	if not hit_data:
		__log_warn("weapon hit data is null", "on_area_contact", "return")
		return

	# if combat is PlayerCombat:
		# prints("contact", em.crucial_x2, "/n", em.crucial_x2)
		
	# __log_("Calling apply_hit with hit data", hit_data)
	combat.apply_hit(hit_data)


func _is_weapon_mine(weapon: BaseWeapon) -> bool:
	if weapon.holder == combat.get_character():
		return true
	return false
	# note: comparing holders is enough for now but we want also to control
	# certain groups of weapons in the future. See Groups.Weapons 

func _to_string() -> String:
	return "name '%s' of Combat '%s'" % [name, combat.get_combat_name()]


var __EXTRA_LOG_B: bool = false


func __log_(...parts: Array):
	# if not combat.is_player():
	print_.hit_box(name, pp.list_(parts))

func __log_extra(...parts: Array):
	# if not combat.is_player():
	if __EXTRA_LOG_B:
		print_.hit_box(name, pp.list_(parts))


func __log_warn(what: String, where: String, fallback: String, ...context: Array):
	print_.warn(false, what, "HitBox " + self.name + " " + where, fallback, pp.list_(context))
