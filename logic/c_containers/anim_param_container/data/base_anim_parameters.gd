class_name BaseAnimParameters
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
## or going through different "paths" of how track can be referenced (awkward)
## UPD: for now it is an awkward options..
