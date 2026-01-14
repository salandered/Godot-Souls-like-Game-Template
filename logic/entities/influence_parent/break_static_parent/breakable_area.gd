@tool
@abstract
class_name BreakableArea
extends CommonArea


## external event
## usually is emitted in on_area_entered
signal _SIG_breaking_area_entered

## public
func get_SIG_breaking_area_entered() -> Signal:
	return _SIG_breaking_area_entered

## to use in implementation
func _emit_SIG_breaking_area_entered() -> void:
	get_SIG_breaking_area_entered().emit()


## CONFIG


func _get_common_area_config() -> CommonAreaConfig:
	return CommonAreaConfig.new(
		MonitorType.PROCESS,
		true,
		false,
		Collision.Masks.PROP_COL_MASK,
		true
	)


## COMMON AREA

var sig_emit_cooldown: Cooldown

func _ready_implementation() -> void:
	sig_emit_cooldown = Cooldown.new(0.2)


func _ready_implementation_non_editor() -> void:
	collision_layer = Collision.Layers.PROP_COL

func _physics_process_implementation(delta: float) -> void:
	pass
