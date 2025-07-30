extends Node
class_name PlayerModel

# todo consider: not a fan of sharing logic between enemy/player

@export var is_enemy: bool = false

@onready var player = $".."
@onready var skeleton = %GeneralSkeleton
@onready var animator = $SplitBodyAnimator
@onready var combat = $Combat as HumanoidCombat
@onready var resources = $Resources as HumanoidResources
@onready var hitbox: Hitbox_ = %HitBox
@onready var legs = $Legs as Legs
@onready var area_awareness = $AreaAwareness as AreaAwareness

@onready var active_weapon: SwordOh = %SwordOh
@onready var states_container = $States as HumanoidStates
# @onready var weapons = {
# 	"sword" = $....Sword,
# 	"bow" = $....Bow,
# 	"greatsword" = $....Greatsword,
# 	....
# }

var current_state: BasePlayerState


func _ready():
	states_container.player = player
	states_container.accept_states()
	current_state = states_container.states["idle"]
	switch_to("idle")
	legs.current_legs_state = states_container.get_state_by_name("idle")
	legs.accept_behaviours()


func update(input: InputPackage, delta: float):
	input = combat.contextualize(input)
	area_awareness.last_input_package = input
	var relevance = current_state.check_relevance(input)
	if relevance != "okay": # todo not okay
		switch_to(relevance)
	current_state.update_resources(delta) # moved back here for now, because of TorsoMoves triggering _update from legs behaviour -> doubledipping
	current_state._update(input, delta)


func switch_to(state: String):
	# if not is_enemy:
		# print(current_state.state_name + " -> " + state)
	current_state._on_exit_state()
	current_state = states_container.states[state]
	current_state._on_enter_state()
