extends BaseSignals
class_name BaseCharacterSignals

signal SFX_footstep(data: Dictionary[String, Variant])
signal SFX_footstep_scrape(data: Dictionary[String, Variant])
signal SFX_launch(data: Dictionary[String, Variant])
signal SFX_land(data: Dictionary[String, Variant])
signal SFX_whoosh(data: Dictionary[String, Variant])
signal SFX_hit_weapon(data: Dictionary[String, Variant])
signal SFX_whoosh_weapon(data: Dictionary[String, Variant])
# signal SFX_react_on_hit


## fs
func get_SFX_footstep() -> Signal:
	return SFX_footstep

func get_SFX_footstep_scrape() -> Signal:
	return SFX_footstep_scrape


## 
func get_SFX_launch() -> Signal:
	return SFX_launch

func get_SFX_land() -> Signal:
	return SFX_land

func get_SFX_whoosh() -> Signal:
	return SFX_whoosh


## weapon
func get_SFX_hit_weapon() -> Signal:
	return SFX_hit_weapon

func get_SFX_whoosh_weapon() -> Signal:
	return SFX_whoosh_weapon

# func get_SFX_react_on_hit() -> Signal:
# 	return SFX_react_on_hit
