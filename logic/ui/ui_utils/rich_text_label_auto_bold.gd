@tool
extends RichTextLabel

@export_multiline var plain_text: String = "":
	set(value):
		plain_text = value
		_format_text()

# List of phrases to make italic
@export var italic_phrases: Array[String] = []

@export var icon_size: int = 20
@export var phrase_icons: Dictionary[String, String] = {}

func _ready():
	bbcode_enabled = true
	fit_content = true
	_format_text()

func _format_text():
	if plain_text.is_empty():
		text = ""
		return
	
	var formatted := ""
	var lines := plain_text.split("\n")
	
	# Step 1: Make text before " - " bold
	for line in lines:
		if " - " in line:
			var parts := line.split(" - ", false, 1)
			if parts.size() >= 2:
				formatted += "[b]" + parts[0] + "[/b] - " + parts[1] + "\n"
			else:
				formatted += line + "\n"
		else:
			formatted += line + "\n"
	
	formatted = formatted.strip_edges()
	
	# Step 2a: Replace phrases with icons first
	for phrase in phrase_icons.keys():
		if phrase.is_empty():
			continue
		var icon_path := phrase_icons[phrase]
		if ResourceLoader.exists(icon_path):
			# Icon + italic phrase
			var replacement := "[img=%dx%d]%s[/img] %s" % [icon_size, icon_size, icon_path, phrase]
			formatted = formatted.replace(phrase, replacement)
	
	# Step 2b: Make remaining phrases italic (ones without icons or not in phrase_icons)
	for phrase in italic_phrases:
		if phrase.is_empty():
			continue
		# Only italicize if not already processed (check if [i] tag already exists around it)
		if not ("[i]" + phrase + "[/i]") in formatted:
			formatted = formatted.replace(phrase, "[i]" + phrase + "[/i]")
	text = formatted
