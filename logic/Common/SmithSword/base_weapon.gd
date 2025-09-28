extends Node3D
class_name BaseWeapon
# CHECKLIST
# Weapon consists of
# - area3D - WeaponHurtBox - PACKED SCENE
#       - collision HurtBoxCol of area3D IS NOT in packed scene, because godot doesnt like scaling col that way
# - weapon visual mesh - optional (e.g. leg kick)
# - holder - assigned by the holder (owner)
# also
# - Scene in owner tree should have group.
# - HurtBoxCol should be adjusted (scale)
# - WeaponHurtBox and Visuals - unique names

## To get a hit only once per attack.
## If hitbox doesn't find itself in the list
##    - it registers the contact
##    - writes itself into the list to ignore all further contacts
## Being cleared by attack states at the end of their life cycle
var hitbox_ignore_list: Array[Area3D]

## deciding between casual animation and a strike
var is_attacking: bool = false

var weapon_name: String
var holder: Node # yes it can be not Node3D
var weapon_hurt_box: WeaponHurtBox
var weapon_visuals: MeshInstance3D = null

var base_damage: float = 10
## Maps input actions to states.
## E.g: Sword maps 'light attack pressed' to slash, while stuff to spell.
## basic_attacks = {
## 	CombatAction.light_attack_pressed: PS.longsword_1
## }
var basic_attacks: Dictionary
var attachment_to_weapon: Transform3D
func _ready():
	# set collision of Weapon
	weapon_hurt_box.base_weapon = self
	weapon_hurt_box.collision_layer = Collision.Layers.WEAPON_AREA
	weapon_hurt_box.collision_mask = Collision.Mask.WEAPON_AREA_MASK

	
	if not weapon_visuals:
		print("Note: Weapon", pp.__, weapon_name, pp.__, "has no visuals")

	assert(weapon_hurt_box is Area3D, "Weapon is missing an Area3D node named 'WeaponArea'.")
	assert(weapon_hurt_box.get_child(0), "The 'WeaponArea' must have a CollisionShape3D child.")
	

func get_hit_data() -> HitData:
	if not __safe_checks():
		return HitData.blank()
	return holder.current_state.pack_hit_data(self)

func __safe_checks() -> bool:
	if not "current_state" in holder:
		push_error("BaseWeapon: " + holder.name + " holder does not have current_state")
		return false
	if not holder.current_state:
		push_error("BaseWeapon: " + holder.name + " holder.current_state is null, cannot get hit data")
		return false
	if not holder.current_state.has_method("pack_hit_data"):
		push_error("BaseWeapon: " + holder.name + " holder.current_state does not have pack_hit_data method, cannot get hit data")
		return false
	return true
