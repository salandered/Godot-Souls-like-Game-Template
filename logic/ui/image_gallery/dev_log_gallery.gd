class_name DevLogImageGallery
extends BaseImageGallery


func get_raw_gallery_items() -> Array[GalleryItem]:
	var list_: Array[GalleryItem] = [
		GalleryItem.new("collage the beginning",
		MISC_PATH,
		"The Beginning"
		),
		GalleryItem.new("collage research",
		MISC_PATH,
		"Early research",
		"...",
		),
		GalleryItem.new("collage c",
		BASE_PATH,
		"Later code",
		),
		GalleryItem.new("collage cam",
		BASE_PATH,
		"Understanding camera movement",
		),
		GalleryItem.new("collage rigs",
		BASE_PATH,
		"Understanding Rigging",
		"finicky, gnarly"
		),
		GalleryItem.new("collage pl",
		BASE_PATH,
		"Main character iterations",
		),
		GalleryItem.new("collage bg",
		BASE_PATH,
		"Final enemy design",
		"His name is Bob, he likes shiny things and hierarchical state machine"
		),
		GalleryItem.new("collage lady",
		BASE_PATH,
		"Water Lady in progress",
		"Originally 'Figure of the dancer'. See 3D museum models"
		),
		GalleryItem.new("collage sunset",
		BASE_PATH,
		"Player animations",
		"Animations contain mechanics data like combo timings, also some SFX"
		),
		GalleryItem.new("collage anim sfx",
		BASE_PATH,
		"Interactive items animations",
		),
		GalleryItem.new("collage figures",
		BASE_PATH,
		"Early debug visuals",
		),
		GalleryItem.new("collage figures 2",
		BASE_PATH,
		"Later debug visuals",
		),
		# GalleryItem.new("collage hitboxes",
		# MISC_PATH,
		# "Hit/Hurtboxes",
		# ),
		GalleryItem.new("collage sk evolution",
		BASE_PATH,
		"Evolution of skeleton visuals",
		"Super cute"
		),
		GalleryItem.new("collage dv ui",
		BASE_PATH,
		"Debug visuals Control Panel",
		),
		GalleryItem.new("collage desert",
		BASE_PATH,
		"Center of the demo level in progress",
		),
		# GalleryItem.new("collage mm3",
		# MISC_PATH,
		# "Working on the Main menu scenery",
		# ),
		GalleryItem.new("collage museum t",
		BASE_PATH,
		"3D museum models",
"3D museum exhibits that formed the basis of some assets.
More info can be found in Credits.",
		),
		GalleryItem.new("collage perf",
		BASE_PATH,
		"Performance issues",
		),
		GalleryItem.new("collage wf",
		BASE_PATH,
		"Wireframe pixelated miniature",
		"[i]Eerie[/i]"
		),
		GalleryItem.new("collage wf2",
		BASE_PATH,
		"Additional wireframe landscapes",
		),
		GalleryItem.new("collage colors",
		BASE_PATH,
		"shapes and colors",
		),
		GalleryItem.new("collage_15",
		BASE_PATH,
		"shapes and colors #2",
		),
	]
	return list_


##


func __LOG_B() -> bool:
	return false
