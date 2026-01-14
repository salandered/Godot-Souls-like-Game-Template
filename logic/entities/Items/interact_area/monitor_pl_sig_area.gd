@tool
class_name MonitorPlayerEnterSignalArea
extends CommonArea


@export var fire_only_once: bool = false


@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D


signal SIG_player_entered(incoming_body: Node3D)


var cooldown_sig_emit := Cooldown.new(0.2)


func _get_common_area_config() -> CommonAreaConfig:
	return CommonAreaConfig.new(
		MonitorType.SIGNAL, # using signals
		false,
		true,
		Collision.Masks.ONLY_PLAYER,
		true
	)


func _get_coll_shape() -> CollisionShape3D:
	return collision_shape_3d


func _ready_implementation() -> void:
	pass


func _ready_implementation_non_editor() -> void:
	pass


func on_body_entered(incoming_body: Node3D) -> void:
	if incoming_body is Princess or incoming_body is FreeCameraBody:
		if cooldown_sig_emit.is_cooldown_passed():
			SIG_player_entered.emit(incoming_body)
			cooldown_sig_emit.mark_time()

			if fire_only_once:
				_shut_down()


func _physics_process_implementation(delta: float) -> void:
	pass


func __LOG_B() -> bool:
	return false
