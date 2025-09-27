extends BaseEncounter

# Story data for this encounter
var encounter_title = "An Unlikely Guide"
var encounter_text = "Nemáš cígo?"

var encounter_choices = [
	{
		"text": "Dát cígo.",
		"next_scene": "res://encounters/PoetryNightEncounter.tscn",
		"effects": {
			"unlock_paths": ["artistic_path"]
		}
	},
	{
		"text": "Sam nemam.",
		"next_scene": "res://encounters/HomeArrivalEncounter.tscn"
	}
]

func _ready():
	encounter_id = "homeless_cigo"
	# Set specific assets for this encounter
	# background_texture = preload("res://assets/backgrounds/hidden_garden.png")
	# character_texture = preload("res://assets/characters/hedgehog.png")
	# ambient_sound = preload("res://assets/audio/garden_ambience.ogg")
	# choice_sound = preload("res://assets/audio/rustling.ogg")
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	scene_text.text = encounter_text
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text

func on_choice_selected(choice_index: int):
	"""Handle choice selection with effects and next scene loading"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	
	# Process effects if they exist
	if choice.has("effects"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.process_effects(choice.effects)
	
	# Load next scene
	if choice.has("next_scene"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.load_encounter(choice.next_scene)

func on_encounter_start():
	# Hedgehog entrance - cute bouncing animation
	play_custom_animation("hedgehog_bounce")
	
	# Add whimsical atmosphere
	await get_tree().create_timer(1.0).timeout
	pulse_character(0.9, 1.5)  # Smaller pulse for cute effect

func load_encounter_data(data: Dictionary):
	super.load_encounter_data(data)
	
	# Add hedgehog charm to the text
	if scene_text:
		scene_text.append_text("\n\n[i]*The hedgehog adjusts its tiny hat with dignity*[/i]")

func _on_left_choice_pressed():
	# Special hedgehog reaction to poetry choice
	if encounter_data.has("choices") and encounter_data.choices.size() > 0:
		var choice_text = encounter_data.choices[0].get("text", "")
		if "poetry" in choice_text.to_lower():
			shake_character(2.0, 0.2)  # Excited hedgehog
	
	super._on_left_choice_pressed()

func _on_right_choice_pressed():
	# Hedgehog waves goodbye if leaving
	if encounter_data.has("choices") and encounter_data.choices.size() > 1:
		var choice_text = encounter_data.choices[1].get("text", "")
		if "leave" in choice_text.to_lower():
			play_custom_animation("hedgehog_wave")
	
	super._on_right_choice_pressed()
