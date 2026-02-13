extends Node3D
class_name RangerWrapper


@onready var long_hair: MeshInstance3D = $"Armature/GeneralSkeleton/long hair"
@onready var ranger_torso: MeshInstance3D = $"Armature/GeneralSkeleton/ranger torso"
@onready var ranger_pants: MeshInstance3D = $"Armature/GeneralSkeleton/ranger pants"
@onready var ranger_boots: MeshInstance3D = $"Armature/GeneralSkeleton/ranger boots"
@onready var ranger_top: MeshInstance3D = $"Armature/GeneralSkeleton/ranger top"
@onready var _mask: MeshInstance3D = $Armature/GeneralSkeleton/_mask
@onready var fancy_hat: MeshInstance3D = %"fancy hat"


const TILE_BLACK_PLASTIC = preload("uid://lg6qj8wpa5va")

const HEALTH_ITEM_SHADER_MAT = preload("uid://i0yd71ruqvup")

# const TRIM_RAIL_PIPE = preload("uid://bs2jei6uvq271")
const FLAT_EMITTER_RED = preload("uid://dauxox1fd0gtl")
# const HEALTH_ITEM_MAT = preload("uid://yv1wf8fj6a2k")
# const CYCLES_GLOW_ORANGE = preload("uid://chilr0f8o2xm5")


func _ready() -> void:
		SigUtils.safe_connect_pairs([
		[GlobalUIInfo.SIG_dvc_color_value_changed, _on_SIG_dvc_color_value_changed],
		[GlobalUIInfo.SIG_dvc_bvalue_changed, _on_SIG_dvc_bvalue_changed],
	])


func super_mats():
	# _super_mat(long_hair, TRIM_RAIL_PIPE, 0)
	# _super_mat(ranger_torso, HEALTH_ITEM_MAT, 0)
	_super_mat(ranger_torso, TILE_BLACK_PLASTIC, 2)
	# _super_mat(ranger_pants, HEALTH_ITEM_MAT, 2)
	# _super_mat(ranger_boots, HEALTH_ITEM_MAT, 0)
	_super_mat(ranger_boots, TILE_BLACK_PLASTIC, 2)
	_super_mat(ranger_top, TILE_BLACK_PLASTIC, 1)
	# _super_mat(_mask, CYCLES_GLOW_ORANGE, 0)


func _super_mat(mesh: MeshInstance3D, mat, index: int):
	if mesh and mat is Material:
		if mesh.get_surface_override_material_count() > index:
			mesh.set_surface_override_material(index, mat)


func _on_SIG_dvc_color_value_changed(payload: Dictionary[String, Variant]):
	var _r := DVCSIGPayloadParser.safe_color_get_value_by_dvc_key(
		payload,
		DVS.KeyColorChanger.HAIR_COLOR
	)
	if _r.err: return

	var new_mat := MaterialUtils.create_standard_3d(_r.value)
	_super_mat(long_hair, new_mat, 0)


func _on_SIG_dvc_bvalue_changed(payload: Dictionary[String, Variant]):
	var _r := DVCSIGPayloadParser.safe_bget_value_by_dvc_key(
		payload,
		DVS.KeyBValueChanger.WEAR_HAT
	)
	if _r.err: return

	_toggle_hat(_r.value)


## temporary
func _toggle_hat(value) -> void:
	# if rig:
	# 	rig.super_mats()
	if fancy_hat:
		fancy_hat.visible = value

##
