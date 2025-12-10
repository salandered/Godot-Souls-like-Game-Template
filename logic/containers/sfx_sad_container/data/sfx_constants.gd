class_name SFXConstants
extends RefCounted


const anim_asp_prefix = "AAnim"
const modifier_key = "modifier"

## todo: used as ID, not checked, but ensure uniqueness
class Type_:
	## fs
	const footstep := "footstep"
	const footstep_light := "footstep_light"
	const footstep_scrape := "footstep_scrape"
	
	##
	const launch := "launch"
	const land := "land"
	const whoosh := "whoosh"

	##
	const move_noise := "move_noise"

	## weapon
	const hit_weapon := "hit_weapon"
	const whoosh_weapon := "whoosh_weapon"


class Modifier:
	const light := "light"
