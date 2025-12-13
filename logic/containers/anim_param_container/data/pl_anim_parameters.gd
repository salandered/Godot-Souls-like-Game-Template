class_name PlAnimParameters
extends Node


# ANIMATED PARAMS ## VARS HERE CORRESPONDS AS IS TO TRACK IN ANIMATION PLAYER 


## DOCS
## DANGER ## On moving AnimParamters or NativeAnimator nodes, 
## 		track paths will be recalculated! 
## Check that TRACK_PREFIXES cover them
##
## Example how it can be changed:
##  from '%AnimParameters:switches_to_queue'
##  to 'AnimatorManager/NativeAnimator/AnimParameters:switches_to_queue'
##
## What can be done in the future: not hard-coded track prefix (some auto search using parameter names)
## or going through different "paths" of how track can be referenced (akward)


# region: switches_to_queue and allows_queue docs
## Another state can be queued while current is playing.
## 'switches_to_queue' means that current action can be switched to queued right now.
## 		E.g: turning it ON in the last part of the combo attack (tail). If queued state exists, we switch
## 'allows_queue' means that the queued state can exist in the first place.
##      E.g.: turning it ON in the middle of the combo attack. 
## 			  If combo logic is satisfied (here it's usually player pressing LMB agagin), next combo attack can be queued
##
## In other words: Current state is 1st combo attack. Player presses LMB again. 2nd combo attack is queued if current state has 'allows_queue' ON.
## As soon as current state turns 'switches_to_queue' ON (if ever), we will switch to 2nd combo attack.
## (Combo logic is implemented in Combo_) 
# endregion
@export var switches_to_queue: bool
@export var allows_queue: bool
## Able to lose health. By default everything is is_vulnerable I guess.
@export var vulnerable: bool
## Basic usage: u ve been hit:
## 		If is_interruptable OFF, nothing changes. E.g:  u dying.
##      If it's ON, logic changes. E.g: force switching to Stagger state.
@export var interruptable: bool
## Is weapon "attacking". Example usage: attack animation hurts others somewhere in the middle of it (e.g. actual sword slash).
## Note that it can be not a real weapon, like a leg kick.
@export var weapon_hurts: bool
## Player can turn (rotate) while performing current animation. 
## Example: in some games (not true souls like, of course) jumping can be controlled as much as a usual running (enables flying around the corner).
@export var tracks_input_vector: bool


# consider return of parryable
## Basic usage: small gap in attack animation where in can be parried (by shield in DS, by catana in Seciro, i guess).
## If u made a sucessfull Parry, u can Riposte (counter attack). This logic is in states, not related to 'is_parryable'.

# consider root_motion
## If animation uses root motion. In theory we can turn it ON and OFF throughout the animation, in practice it's binary I quess.
## We can turn it OFF if it's unwelcomed in some loco animation as well
