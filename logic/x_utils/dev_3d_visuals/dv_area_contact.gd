@tool
@icon("uid://fg14dl1y5rwc")

class_name DVAreaContact
extends Node3DSystem


@export var char_hit_box: CharacterHitbox

## WARNING: currently works with CharacterHitbox only


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	await FrameUtils.wait_process_frames(4)
	
	if not char_hit_box:
		return


	SigUtils.safe_connect_pairs([
			[GlobalUIInfo.SIG_dvc_value_changed_section_vc, _on_SIG_dvc_value_changed_section_vc],
			[char_hit_box.SIG_incoming_area_contacted, _on_SIG_incoming_area_contacted]
		])
	

func _on_SIG_incoming_area_contacted(payload: Dictionary[String, Variant]):
	__log_("_on_SIG_incoming_area_contacted", payload)
	if not char_hit_box:
		return
	var _r_ma = SigUtils.safe_get_variant_payload_value(payload, char_hit_box.my_area_field, false)
	if _r_ma.err or _r_ma.value is not Area3D: return
	var _r_ia = SigUtils.safe_get_variant_payload_value(payload, char_hit_box.incoming_area_field, false)
	if _r_ia.err or _r_ia.value is not Area3D: return

	var hit_pos := Area3DUtils.get_area_contact_point(_r_ma.value as Area3D, _r_ia.value as Area3D)
	
	if hit_pos != Vector3.INF:
		# VISUALISE
		# 1. Draw Hit Point (Gold Sphere, 0.1 radius, lasts 2.0 seconds)
		MeshInstanceUtils.debug_draw_sphere(self , hit_pos, 0.1, Color.GOLD, 10.0)
		
		# 2. Draw Tracer Line (Red Line from self to hit, 0.02 thickness, lasts 0.5 seconds)
		MeshInstanceUtils.debug_draw_line(self , global_position, hit_pos, 0.02, Color.RED, 5.5)


func _on_SIG_dvc_value_changed_section_vc(payload: Dictionary[String, Variant]):
	if not char_hit_box:
		return
	var parsed_payload := SigPayloadParser.safe_get_SIG_dvc_value_changed_section_payload(payload)
	if not parsed_payload or parsed_payload.value is not bool:
		return
	
	match parsed_payload.key:
		DVS.KeyValueChanger.WEAPON_HIT:
			char_hit_box.emit_on_attacking_wp = parsed_payload.value as bool
		DVS.KeyValueChanger.WEAPON_HIT_EVERY_FRAME:
			char_hit_box.emit_on_attacking_wp_every_frame = parsed_payload.value as bool


##

func __LOG_B() -> bool:
	return true