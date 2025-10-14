@tool
@icon("res://-assets-/x_misc/x_icons/red/hurt_box_3d.svg")
extends Area3D
class_name WeaponHurtBox

## Weapon area which damages.
## base_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info

var base_weapon: BaseWeapon
