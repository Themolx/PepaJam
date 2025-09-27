extends BaseEncounter

# Story data for this encounter
var encounter_title = "Midnight Munchies"
var encounter_text = "The food truck owner, a cheerful man named Gary, serves you the most amazing kebab you've ever tasted. 'Secret ingredient is love!' he winks. You feel energized and ready for anything."

var encounter_choices = [
	{
		"text": "Ask Gary for life advice",
		"next_scene": "res://encounters/GaryWisdomEncounter.tscn",
		"effects": {
			"unlock_paths": ["wisdom_path"]
		}
	},
	{
		"text": "Thank him and continue home",
		"next_scene": "res://encounters/HomeArrivalEncounter.tscn"
	}
]

func _ready():
	encounter_id = "food_truck"
	# Set specific assets for this encounter
	# background_texture = preload("res://assets/backgrounds/street_night.png")
	# character_texture = preload("res://assets/characters/gary_vendor.png")
	# ambient_sound = preload("res://assets/audio/street_noise.ogg")
	# choice_sound = preload("res://assets/audio/cash_register.ogg")
	
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
	# Gary's food truck has sizzling sounds and warm lighting
	pulse_character(1.1, 2.0)
	
	# Add food truck atmosphere
	await get_tree().create_timer(0.5).timeout
	play_custom_animation("sizzle_effect")

func load_encounter_data(data: Dictionary):
	super.load_encounter_data(data)
	
	# Add special food truck flavor to the text
	if scene_text:
		scene_text.append_text("\n\n[i]The smell of grilled meat fills the air...[/i]")

func on_encounter_end():
	super.on_encounter_end()
	# Gary waves goodbye
	play_custom_animation("wave_goodbye")
