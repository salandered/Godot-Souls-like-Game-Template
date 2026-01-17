class_name GenericImageGallery
extends BaseImageGallery


func get_raw_gallery_items() -> Array[GalleryItem]:
	var list_: Array[GalleryItem] = [
		GalleryItem.new("collage the beginning", BASE_PATH),
		GalleryItem.new("collage figures", BASE_PATH,
		"TEST TITLE",
"[b]test description[/b] - desc
another line
"
		),

	]
	return list_
