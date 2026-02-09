@abstract
class_name BaseMetricsGridManager
extends BasePanelManager


## distributor
@export var metrics_grid: MetricsGridDistributor
@export var ui_container: Container


var _metrics_grid: MetricsGridDistributor


func get_ui_panel() -> Container:
	return ui_container


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_metrics_grid
	]


func _ready_imp() -> void:
	_metrics_grid = metrics_grid

	
func _supported_signal_pairs() -> Array[Array]:
	return []
