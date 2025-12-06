@tool
extends BasePlayerWeapon
class_name SmithSword

@onready var _weapon_hurt_box_: WeaponHurtBox = $WeaponHurtBox
@onready var _visuals_: Node3D = $Visuals

@onready var weapon_sfx: WeaponSFX = $WeaponSFX

const WEAPON_WHOOSH = preload("uid://qufmydm4eeq4")
const SWORD_HIT_BONES = preload("uid://g4dtkcleinh8")


var hit_sounds: Dictionary = {
	# "Material:Wood": preload("res://your_path/hit_wood.wav"),
	# "Material:Stone": preload("res://your_path/hit_stone.wav"),
	# "Material:Flesh": preload("res://your_path/hit_flesh.wav"),
	# "Default": preload("res://your_path/hit_metal_default.wav")
}

func initialise_implementation() -> void:
	var mesh: MeshInstance3D = _visuals_.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	_input_action_to_state = {
		# CombatAction.light_attack_pressed: PS.axe_slice_1,
		CombatAction.light_attack_pressed: PS.sword_slash_1,
		# CombatAction.light_attack_pressed_when_move: PS.attack_from_run
	}
	
func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_pp_name() -> String:
	return WeaponNames.smith_sword


func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_


## SFX

func get_weapon_audio_system() -> BaseWeaponAudioSystem:
	return weapon_sfx.get_audio_system()


func set_whoosh_weapon_stream():
	weapon_sfx.set_whoosh_weapon_stream(WEAPON_WHOOSH)

func set_hit_weapon_stream():
	weapon_sfx.set_hit_weapon_stream(SWORD_HIT_BONES)

# func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream:
# 	for material in hit_sounds.keys():
# 		if target.is_in_group(material):
# 			return hit_sounds[material]
# 	return hit_sounds.get("Default", null)
