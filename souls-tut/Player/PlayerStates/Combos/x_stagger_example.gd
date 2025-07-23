extends Combo

# @export var root_state: BasePlayerState

# # @export var panic_click_block: float

# # @export var primary_input: String "stagger"

# # @export var next_attack: String

# @export var animation: String = "react_on_floor"

# @export var has_poise: bool = false
# @export var poise_start: float
# @export var poise_end: float

# # func _ready():
# # 	triggered_state = next_attack


# func is_triggered(input: InputPackage) -> bool:
# 	if input.actions.has("stagger") and not (has_poise and root_state.works_between(poise_start, poise_end)):
# 		return true
# 	return false


# Godot has a specific term for a node plus script package with manageable constants: it's called a 'scene.' 
# - Stagger is a combo that will be nested into its states in the form of a scene.
# - This scene has the same script trigger but has different timing windows that you can even export and edit them directly here in the editor.