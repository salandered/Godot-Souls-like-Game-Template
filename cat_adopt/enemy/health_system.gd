@icon("res://-assets-/x_icons/heart_green.png")
class_name HealthSystem extends Node

## A very crude health system. A 'hit' reporting node, (player or hit box, etc)
## can emit a damaging signal, or healing signal. That signal should pass the
## the attacking node's information. This system checks for "node.power" of the attack
## or healing effect, and then applies that to healing or hurting.

## It can also work with a "health bar controller" or enemies to show their
## on-screen healthbar for a few seconds after being hit or healed.

@export var total_health: int = 5
@export var health_bar_control: Control
@onready var current_health = total_health


signal health_updated