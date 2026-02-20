@tool
@icon("uid://fg14dl1y5rwc")

class_name DVHitBoxAreaContact
extends BaseDVCDependentNode3D


@export var char_hit_box: CharacterHitbox
@export var character: BaseStaticCharacter
@export var draw_snapped_hits: bool = DEF_draw_snapped_hits
@export var hard_off_snapped_hits: bool = false
@export var shading_mode: BaseMaterial3D.ShadingMode = DEF_SHADED
@export var duration: float = BASE_DUR


const BASE_DUR := 3.5
const DEF_SHADED := BaseMaterial3D.SHADING_MODE_PER_PIXEL
const DEF_draw_snapped_hits := true


func initialise() -> void:
	if u.is_editor():
		return
	
	await FrameUtils.wait_process_frames(4)
	
	if not char_hit_box:
		return

	if not character:
		return

	SigUtils.safe_connect_pairs([
			[GlobalUIInfo.SIG_dvc_bvalue_changed, _on_SIG_dvc_bvalue_changed],
			[GlobalUIInfo.SIG_dvc_fvalue_changed, _on_SIG_dvc_fvalue_changed],
			[char_hit_box.SIG_incoming_weapon_contacted, _on_SIG_incoming_weapon_contacted]
		])


func reset_visuals() -> void:
	pass


func _on_SIG_incoming_weapon_contacted(payload: Dictionary[String, Variant]):
	__log_("_on_SIG", payload)
	if not char_hit_box:
		return
	var _r_ma := SigUtils.safe_get_variant_payload_value(payload, char_hit_box.my_area_field, false)
	if _r_ma.err or _r_ma.value is not Area3D: return
	var _r_ia := SigUtils.safe_get_variant_payload_value(payload, char_hit_box.incoming_area_field, false)
	if _r_ia.err or _r_ia.value is not Area3D: return
	var _r_in_c_l := SigUtils.safe_get_bool_payload_value(payload, char_hit_box.in_contact_list_field)
	if _r_in_c_l.err: return

	var my_area := _r_ma.value as Area3D
	var in_contact_list := _r_in_c_l.value
	var is_invincible := character.is_invincible()

	var hit_pos := Area3DUtils.get_area_contact_point(my_area, _r_ia.value as Area3D)
	
	if hit_pos == Vector3.INF:
		return

	if not is_invincible:
		if not in_contact_list:
			_draw_standard_hit(my_area, hit_pos, true, null)
		else:
			_draw_secondary_hit(my_area, hit_pos)
	else:
		if not in_contact_list:
			_draw_standard_hit(my_area, hit_pos, true, Color.LIME)
		else:
			_draw_secondary_hit(my_area, hit_pos, true, Color.MEDIUM_AQUAMARINE)


var standard_color := Color.CRIMSON
var secondary_color := Color.FIREBRICK
var standard_size := 0.04


func _draw_standard_hit(
	my_area: Area3D,
	hit_pos: Vector3,
	draw_both_levels: bool = true,
	color_override: Variant = null,
	size_mult: float = 1.0,
	dur_mult: float = 1.0
):
	var color: Color = color_override if color_override is Color else standard_color
	MeshInstanceUtils.draw_temporary_sphere(
		my_area,
		hit_pos,
		standard_size * size_mult,
		color,
		duration * dur_mult,
		true,
		shading_mode)
	if draw_both_levels and draw_snapped_hits and not hard_off_snapped_hits:
		MeshInstanceUtils.draw_temporary_sphere(
			my_area,
			hit_pos,
			standard_size * 0.9 * size_mult,
			color.darkened(0.4),
			duration * 0.8 * dur_mult,
			false,
			shading_mode)


func _draw_secondary_hit(my_area: Area3D, hit_pos: Vector3, draw_both_levels: bool = true, color_override: Variant = null):
	var color: Color = color_override if color_override is Color else secondary_color
	_draw_standard_hit(
		my_area,
		hit_pos,
		draw_both_levels,
		color,
		0.5,
		0.6,
	)


func _on_SIG_dvc_fvalue_changed(payload: Dictionary[String, Variant]):
	if not char_hit_box:
		return
	var parsed_payload := DVCSIGPayloadParser.parse_untyped_dvc_value_changed(payload)
	if not parsed_payload or not parsed_payload.value is float:
		return
	var dvc_key := parsed_payload.key
	var value := parsed_payload.value as float

	match dvc_key:
		DVS.KeyFValueChanger.WEAPON_HIT_DUR:
			# __log_("_on_SIG_dvc_bvalue_changed", "WEAPON_HIT_DUR", value, typeof(value))
			duration = value
			# __log_("duration", duration)

			
func _on_SIG_dvc_bvalue_changed(payload: Dictionary[String, Variant]):
	if not char_hit_box:
		return
	var parsed_payload := DVCSIGPayloadParser.parse_b_dvc_value_changed(payload)
	if not parsed_payload:
		return
	var dvc_key := parsed_payload.key
	var toggle := parsed_payload.value_as_bool
	match dvc_key:
		DVS.KeyBValueChanger.WEAPON_HIT:
			char_hit_box.emit_on_attacking_wp = toggle
		DVS.KeyBValueChanger.WEAPON_HIT_EVERY_FRAME:
			char_hit_box.emit_on_attacking_wp_every_frame = toggle

		DVS.KeyBValueChanger.WEAPON_HIT_SHADED:
			var _shading_mode := BaseMaterial3D.SHADING_MODE_PER_PIXEL if toggle else BaseMaterial3D.SHADING_MODE_UNSHADED
			shading_mode = _shading_mode
		DVS.KeyBValueChanger.WEAPON_HIT_SNAPPED_HITS:
			draw_snapped_hits = toggle
	

##
func __LOG_B() -> bool:
	return false
