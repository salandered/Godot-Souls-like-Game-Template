extends RefCounted
class_name SignalID

## TODO UPD: bad idea, could be deleted. not maintanable at all
##      should be auto created using signal object name, at least
## todo: not checked, so make sure all unique

## fs like
const sfx_footstep := "SFX_footstep"
const sfx_footstep_light := "SFX_footstep_light"
const sfx_footstep_scrape := "SFX_footstep_scrape"
const sfx_move_noise := "SFX_move_noise"
const sfx_jingles := "SFX_jingles"

##
const sfx_launch := "SFX_launch"
const sfx_land := "SFX_land"
const sfx_whoosh := "SFX_whoosh"

##
const sfx_react_on_hit := "SFX_react_on_hit"

## weapon
const sfx_whoosh_weapon := "SFX_whoosh_weapon"
const sfx_hit_weapon := "SFX_hit_weapon"
# weapon may fake 'receiver' impact sound
const sfx_hit_target := "SFX_hit_target"

##
const sfx_unique := "SFX_unique"

## 
const sfx_switch_weapon := "SFX_switch_weapon"


## GLOBAL

const player_change_health := "GLOBAL_player_change_health"
const player_max_health_increase := "GLOBAL_player_health_increase"
const player_max_stamina_increase := "GLOBAL_player_stamina_increase"
const player_speed_increase := "GLOBAL_player_speed_increase"
const player_dodge_increase := "GLOBAL_player_dodge_increase"
