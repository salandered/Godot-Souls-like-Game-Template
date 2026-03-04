class_name TutorialUI
extends NodeLogger


## assign it to node somewhere close the FirstTutorial or similar

@onready var legend_panel: PanelContainer = %LegendPanel
@onready var tutorial_panel: PanelContainer = %TutorialPanel


# Maps number keys to tutorial panel nodes
var _tutorial_panels: Dictionary[int, Control] = {}
var _cycler: Cycler
var panel_amount: int

func register_panel(key_number: int, panel: Control) -> void:
	if key_number < 1:
		__log_error("TutorialOverlay: key_number must be >= 1")
		return
	
	if not panel:
		return
		
	_tutorial_panels[key_number] = panel
	panel.hide()


func unregister_panel(key_number: int) -> void:
	_tutorial_panels.erase(key_number)


func initialize() -> void:
	var hidden_state := 0
	var keys = [hidden_state] # 0 represents "No Panels Visible"
	
	var registered_keys = _tutorial_panels.keys()
	registered_keys.sort()
	
	panel_amount = len(registered_keys)
	
	keys.append_array(registered_keys)
	
	# Initialize cycler starting at index 0 (which is our '0' key / hidden state)
	_cycler = Cycler.new(keys, hidden_state)

	_apply_state(hidden_state)


func hide_all() -> void:
	for panel in _tutorial_panels.values():
		if panel:
			panel.hide()


func is_any_visible() -> bool:
	for panel in _tutorial_panels.values():
		if panel and panel.visible:
			return true
	return false


func _apply_state(key_number: int) -> void:
	if key_number == 0:
		hide_all()
		tutorial_panel.visible = false
		
	elif _tutorial_panels.has(key_number):
		var panel: Control = _tutorial_panels[key_number]
		if panel:
			tutorial_panel.visible = true
			hide_all()
			panel.show()
			
	SigUtils.safe_emit(GlobalSignal.SIG_tut_panel_switched,
		{
			## 0 means not the first panel, but state when all panels are hidden
			SPS.number_field: key_number,
			SPS.amount_field: panel_amount
		})


func _unhandled_input(event: InputEvent) -> void:
	if not _cycler:
		return

	var new_key: Variant
	
	match InputUtils.get_keycode(event):
		KEY_DOWN:
			new_key = _cycler.get_next()
			_apply_state(new_key)
			InputUtils.mark_input_handled(self )
		KEY_UP:
			new_key = _cycler.get_previous()
			_apply_state(new_key)
			InputUtils.mark_input_handled(self )
