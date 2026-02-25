@tool

@abstract
class_name BaseMetricsGridManager
extends BasePanelManager


## distributor
@export var metrics_grid: MetricsGridDistributor
@export var ui_container: Container
##
@export var use_process: bool = true


var _metrics_grid: MetricsGridDistributor


func get_ui_panel() -> Container:
	return ui_container


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_metrics_grid
	]


func _supported_signal_pairs() -> Array[Array]:
	return []


func initialise_implementation() -> void:
	_metrics_grid = metrics_grid
	if not use_process: set_process(false)


## can be overriden
func nth_frame() -> int:
	return 1


func _process(delta: float) -> void:
	if not use_process: return
	if not _metrics_grid: return

	if not FrameUtils.is_nth_frame(nth_frame()):
		return

	_process_implementation(delta)


func _process_implementation(delta):
	return

	
func set_enabled(value: bool):
	super.set_enabled(value)
	if use_process:
		set_process(value)
