@tool
class_name FirstTutorialContent
extends NodeSystem


@onready var legend: RichTextLabel = %Legend
@onready var controls: RichTextLabel = %Controls
@onready var mechanics_overview: RichTextLabel = %MechanicsOverview
@onready var attack_mechanic: RichTextLabel = %AttackMechanic
@onready var target_lock_mechanic: RichTextLabel = %TargetLockMechanic
@onready var health_stamina_mechanic: RichTextLabel = %HealthStaminaMechanic
@onready var additional_movement_tips: RichTextLabel = %AdditionalMovementTips
@onready var ui_dv_menu_info: RichTextLabel = %UIDVMenu


@export var refill: bool = false:
	set(value):
		refill = false
		if value and Engine.is_editor_hint() and is_node_ready():
			set_all_texts()


const icon_lever = "uid://ciggpdm7q6lei"
const icon_parchment = "uid://qg53gkfhnevx"
const icon_sword = "uid://dhhcof4kym2tu"
const icon_target_2 = "uid://dp2m7ljkctl4"
const icon_heart = "uid://b6duqo7n72nd"
const icon_light_bulb = "uid://cidp1ip2hiw1f"
const icon_interrogation = "uid://califiygvfo0n"
const icon_steps = "uid://bmwjt7mmr0hy8"
const icon_ui_overlay = "uid://faceud5if8lb"
const icon_hand = "uid://dp87v6bn53hy5"
const icon_dodge = "uid://covd6kks862ko"


const add_before: Dictionary[String, String] = {
	# "Controls": icon_lever,
	"Mechanics overview": icon_parchment,
	"Combo attacks": icon_sword,
	# "Target lock": icon_target_2,
	# "target locked": icon_target_2,
	# "target lock button": icon_target_2,
	"target lock": icon_target_2,
	"Health/stamina": icon_heart,
	"Additional info": icon_light_bulb,
	"attack button": icon_sword,
	"Help:": icon_interrogation,
	"Tip:": icon_light_bulb,
	"Advanced tip:": icon_light_bulb,
	"move button": icon_steps,
	"UI Overlay": icon_ui_overlay,
	"dodge button": icon_dodge,
}


const italics_phrases: Array[String] = [
	"attack button",
	"switch weapon button",
	"target lock button",
	"dodge button",
	"move button"
]

func _ready() -> void:
	set_all_texts()


	if not Engine.is_editor_hint():
		SigUtils.safe_connect(GlobalSignal.SIG_tut_panel_switched, _on_SIG_tut_panel_switched)


func set_all_texts():
	__log_("set_all_texts")


	_update_legend_pointer(0)

	_set_text_for_panel(_1_controls_text, controls)
	_set_text_for_panel(_2_mechanics_overview_text, mechanics_overview)
	_set_text_for_panel(_3_attack_mechanic_text, attack_mechanic)
	_set_text_for_panel(_4_target_lock_mechanic_text, target_lock_mechanic)
	_set_text_for_panel(_5_health_stamina_mechanic_text, health_stamina_mechanic)
	_set_text_for_panel(_6_additional_movement_tips_text, additional_movement_tips)
	_set_text_for_panel(_ui_overlay_controls_text, ui_dv_menu_info)


func _set_text_for_panel(raw_text: String, label: RichTextLabel):
	if not label:
		return
	var r_text = raw_text
	r_text = _format_text(r_text, add_before)

	label.text = r_text


func _format_text(raw_text: String, add_before_: Dictionary[String, String]) -> String:
	var _r = ""
	var _icon_replacers: Dictionary[String, String] = {}
	for key in add_before_.keys():
		var icon_path = add_before_[key]
		# __log_("icon_path", icon_path)
		_icon_replacers[key] = BB.image_20_wrap(icon_path) + " " + key
	_r = StrUtils.replace_text_fragments(raw_text, _icon_replacers)
	var _italics_replacers: Dictionary[String, String] = {}
	for phrase in italics_phrases:
		_italics_replacers[phrase] = BB.i_wrap(phrase)
	_r = StrUtils.replace_text_fragments(_r, _italics_replacers)
	return _r


func _update_legend_pointer(active_index: int):
	var content_string = ""
	
	for legend_item_idx in range(LEGEND_ITEMS.size()):
		var item_name = LEGEND_ITEMS[legend_item_idx]
		# active_index = 1 corresponds to the first panel. while with legend_item_idx it's 0
		if legend_item_idx == active_index - 1:
			# gold color, arrow prefix
			content_string += "[color=#ffdd00] > " + item_name + "[/color]\n"
		else:
			# white color and spaces indent
			content_string += "[color=#ffffff]" + "    " + item_name + "[/color]\n"
	content_string = content_string.strip_edges()
	var final_raw_text = LEGEND_HEADER + content_string + LEGEND_FOOTER
	
	_set_text_for_panel(final_raw_text, legend)


func _on_SIG_tut_panel_switched(payload: Dictionary[String, Variant]):
	var _r_number := SigUtils.safe_get_int_payload_value(payload, SPS.number_field)
	if _r_number.err:
		return
	var number := _r_number.value
	_update_legend_pointer(number)
	

##

var LEGEND_ITEMS: Array[String] = [
	BB.image_20_wrap(icon_lever) + " Controls",
	"Mechanics overview",
	"Combo attacks",
	BB.image_20_wrap(icon_target_2) + " Target locking",
	"Health/stamina",
	"Additional info",
	"UI Overlay controls",
	

]

const LEGEND_HEADER = "
[b]Available tutorials[/b]
[hr color=web_gray]
"
const LEGEND_FOOTER = "
[hr color=web_gray]
[i]Use [b]Up/Down[/b] arrows to scroll the tutorials[/i]
[i]Press [b]T[/b] to toggle this panel[/i]
"


var _1_controls_text = "
[ul]
[b]WASD[/b] - " + BB.image_20_wrap(icon_steps) + " move
[b]Space[/b] - " + BB.image_20_wrap(icon_dodge) + " dodge/jump
[b]Shift[/b] - sprint
[b]Q[/b] - target lock
[b]LMB[/b] - " + BB.image_20_wrap(icon_sword) + " light attack
[b]RMB[/b] - " + BB.image_20_wrap(icon_sword) + " heavy attack
[b]E[/b] - " + BB.image_20_wrap(icon_hand) + " interact
[b]F[/b] - switch weapon
[b]Esc[/b] - pause
[/ul]
[hr color=web_gray]
[ul]
[i]H to unstuck (just in case)[/i]
[i]F3 to see profiler[/i]
[i]F9 to toggle flying dev camera[/i]
[/ul]
"


const _2_mechanics_overview_text = "
[b]Attacks and combos[/b] - press light and heavy attack buttons in different order to learn combos. 
Use the [i]switch weapon button[/i] to try different weapons. Note that you can't switch in the middle of the attack (sound clue will help you notice that) 

[b]Dodging[/b] - dodge to evade the enemy attack.

[b]Target locking[/b] and [b]Health/Stamina[/b] - see the dedicated tutorial.

[b]Destructible columns[/b] - let the enemy hit the column, or use more powerful weapon. If you are lucky enough, you will break a column while being thrown away at it by the enemy...

[b]Fighting several enemies at once[/b] - just find the way to reach additional enemies. It's a lot of fun and they could accidently hit each other as well.

[b]Chests and items[/b] - open chests to find helpful items and improve your abilities (e.g. longer dodge).

[hr color=web_gray width=90% align=l]
Tip: on any level you can find mechanical combat dummy. It will help you to learn how to fight, move, and dodge different attack types.
"


const _3_attack_mechanic_text = "
[b]Heavy attack[/b] - just press heavy attack button.

[b]Light combo[/b] - press light attack button two times. 

[b]Full combo[/b] - make light combo and then press heavy attack button. Note that heavy attack is faster (and deadlier) if it comes at the end of the Full combo.

[b]Running attack[/b] - press attack button while sprinting.

[b]Dodge attack[/b] - press attack button right after dodging. Forward dodge results in stab almost immediately. 

[b]And more[/b] - combine light and heavy attack sequence to find new combos.

[hr color=web_gray width=90% align=l]
Help: If combo attack is not triggered, try to press attack button closer to the end of the current attack (less spam the clicks).

Tip: you can change direction in the middle of some attacks if not target locked.
"


const _4_target_lock_mechanic_text = "
[b]Target locking[/b] - find the suitable target and press target lock button. It will allow you to strafe around the target and make you hits more focused. Note that you may sprint freely while in target-lock mode.

[b]Static targets[/b] - you can practice strafing while being in target-lock mode using static targets (golden posts, for example). 

[hr color=web_gray width=90% align=l]
Tip: use vertical mouse movement to adjust the view. 

Advanced tip: you can not only sprint, but also run freely while being in target-lock mode. 
In order to do so double-tap the [i]target lock button[/i] while already being in target lock mode. Double tapping again will switch you back to strafing.
"


const _5_health_stamina_mechanic_text = "
[b]Stamina management[/b] - some moves drain stamina, while others like idle or running will help replenish it.

[b]Stamina fatigue[/b] - when stamina hits zero, you won't be able to make stamina draining moves for a little while. Stamina bar will be painted in yellow and you also will hear a sound clue if a move is not allowed.

[b]Chest items[/b] - you will find pickable items which would help you to improve health and also increase the maximum health/stamina.
"


const _6_additional_movement_tips_text = "
[b]Advanced dodge[/b] - press both the move button and [i]dodge button[/i] simultaneously and then immediately release them. This will make you dodge as if you were being in a target-lock mode. Pretty handy against the projectiles. 

[b]Sprint jump[/b] - just jump while sprinting!

[b]U-turn[/b] - press the opposite move button while sprinting. Helps for quick retreats.

[b]Sprint start[/b] - press shift while idle and only then start moving. It looks cool but is not really helpful.
"

const _ui_overlay_controls_text = "
In Pause Menu you can find UI Overlay Controls submenu. 
It controls all of the in-game UI panels, including this tutorial.

Also a lot of the game mechanics can be visualised using it. To name a few:
[ul]
Current state of the player or any enemy/NPC in game. 
Information about attack type, damage or speed.
Trajectory of the weapon hits.
Character hit boxes and their i-frames (like during the dodge).
Camera setup with all it's nodes.
Additional camera to show character from different sides.
[/ul]

"
