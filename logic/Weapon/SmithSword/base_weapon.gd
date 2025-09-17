extends Node3D
class_name BaseWeapon

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
var weapon_handle: Marker3D
var weapon_visuals: MeshInstance3D

var target_attachment: Node3D

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

#var _calc_attachment_to_weapon: bool = true
#func _process(delta: float) -> void:
	#if _calc_attachment_to_weapon:
		## how the weapon is positioned relative to the attachment at design time
		#attachment_to_weapon = target_attachment.global_transform.affine_inverse() * global_transform
		#_calc_attachment_to_weapon = false
#
	#global_transform = target_attachment.global_transform * attachment_to_weapon
#


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
