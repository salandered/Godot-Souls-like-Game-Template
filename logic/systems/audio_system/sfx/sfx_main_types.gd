extends Node
## autoload class_name SfxType


var footstep: SFXGlue
var footstep_light: SFXGlue
var footstep_scrape: SFXGlue
var launch: SFXGlue
var land: SFXGlue
var whoosh: SFXGlue
var hit_weapon: SFXGlue
var whoosh_weapon: SFXGlue


func _ready() -> void:
	## fs
	footstep = SFXGlue.new(
		"footstep",
		anim_stream_player_prefix + "FS"
		)
	footstep_light = SFXGlue.new(
		"footstep_light",
		anim_stream_player_prefix + "FSLight"
		)
	footstep_scrape = SFXGlue.new(
		"footstep_scrape",
		anim_stream_player_prefix + "FSScrape"
		)

	## 
	launch = SFXGlue.new(
		"launch",
		anim_stream_player_prefix + "Launch"
		)
	land = SFXGlue.new(
		"land",
		anim_stream_player_prefix + "Land"
		)
	whoosh = SFXGlue.new(
		"whoosh",
		anim_stream_player_prefix + "WH"
		)

	## weapon
	hit_weapon = SFXGlue.new(
		"hit_weapon",
		anim_stream_player_prefix + "HitWeapon"
		)
	whoosh_weapon = SFXGlue.new(
		"whoosh_weapon",
		anim_stream_player_prefix + "WHWeapon"
		)
	

const anim_stream_player_prefix = "AAnim"
const modifier_key = "modifier"
class Modifier:
	const light := "light"
	# const scrape := "scrape"
