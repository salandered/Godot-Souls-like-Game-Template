extends AnimationPlayer
class_name StatesDatabase

## EXPORTS
## VARS HERE CORRESPONDS AS IS TO TRACK IN ANIMATION PLAYER WHICH ACTS AS STATES DB.

## Another state can be queued while current is playing.
## 'transitions_to_queued' means that current action can be switched to queued right now.
## 		E.g: turning it ON in the last part of the combo attack (tail). If queued state exists, we switch
## 'accepts_queueing' means that the queued state can exist in the first place.
##      E.g.: turning it ON in the middle of the combo attack. 
## 			  If combo logic is satisfied (here it's usually player pressing LMB agagin), next combo attack can be queued
##
## In other words: Current state is 1st combo attack. Player presses LMB again. 2nd combo attack is queued if current state has 'accepts_queueing' ON.
## As soon as current state will turn 'transitions_to_queued' ON, we will switch to 2nd combo attack.
## (Combo logic is implemented in Combo_) 
@export var transitions_to_queued: bool
@export var accepts_queueing: bool
## Basic usage: small gap in attack animation where in can be parried (by shield in DS, by catana in Seciro, i guess).
## If u made a sucessfull Parry, u can Riposte (counter attack). This logic is in states, not related to 'is_parryable'.
@export var is_parryable: bool
## Able to lose health. By default everything is is_vulnerable I guess.
@export var is_vulnerable: bool
## Basic usage: u ve been hit:
## 		If is_interruptable OFF, nothing changes. E.g:  u dying.
##      If it's ON, logic changes. E.g: force switching to Stagger state.
@export var is_interruptable: bool
## Is weapon "attacking". Example usage: attack animation hurts others somewhere in the middle of it (e.g. actual sword slash).
## Note that it can be not a real weapon but an animation where leg kicks.
@export var weapon_hurts: bool
## Player can turn (rotate) while performing current animation. 
## Example: in some games (not true souls like, of course) jumping can be controlled as much as a usual running (enables flying around the corner).
@export var tracks_input_vector: bool
## If animation uses root motion. In theory we can turn it ON and OFF throughout the animation, in practice it's binary I quess.
## We can turn it OFF if it's unwelcomed in some loco animation as well
@export var root_motion: bool


## ALIASES
## For creating track names

const STATES_DB := "StatesDatabase"

const TRANSITIONS_TO_QUEUED := "transitions_to_queued"
const ACCEPTS_QUEUEING := "accepts_queueing"
const IS_PARRYABLE := "is_parryable"
const IS_VULNERABLE := "is_vulnerable"
const IS_INTERRUPTABLE := "is_interruptable"
const WEAPON_HURTS := "weapon_hurts"
const TRACKS_INPUT_VECTOR := "tracks_input_vector"
const ROOT_MOTION := "root_motion"


## WRAPPERS
## Wrappers around built in AnimationPlayer API.
## Minimul logic here is expected. While StatesDataRepository should be smart.

func get_anim(anim: String) -> Animation:
	if has_animation(anim):
		return get_animation(anim)
	else:
		return null
