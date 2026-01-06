@tool
@icon("res://-assets-/x_icons/level/icon_level_blue_alt.png")

class_name DemoLevel
extends BaseLevel


func basic_tonemap_exposure() -> float:
	return 1.6

func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.1


func initialise() -> void:
	for item in get_descendants.rigid_bodies(self):
		# print_.prefix_s("~~~~~~~~~", item, item.name)
		item.collision_layer = Collision.Layers.ITEM_COL
		item.collision_mask = Collision.Masks.ITEM_COL_MASK
		# print_.collisions(item)


	for item in get_descendants.static_bodies(self):
		# if item is BreakableStatic:
			# item.collision_layer = Collision.Layers.ENVIRONMENT_COL | Collision.Layers.PROP_COL
		# else:
		item.collision_layer = Collision.Layers.ENVIRONMENT_COL
