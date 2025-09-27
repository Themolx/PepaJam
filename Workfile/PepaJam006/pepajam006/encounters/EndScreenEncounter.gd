extends BaseEncounter

# Story data for this encounter
var encounter_title = "Konec"
var encounter_text = "Děkujeme za hraní! Chcete začít znovu?"

var encounter_choices = [
	{
		"text": "Začít znovu",
		"action": "restart_game"
	},
	{
		"text": "Ukončit hru",
		"action": "quit_game"
	}
]

func _ready():
	encounter_id = "end_screen"
	
	# Customize typewriter settings for end screen
	set_typewriter_mode("word")
	set_typewriter_speed(0.1)  # Slower for dramatic effect
	
	# Customize blur settings for end screen
	set_blur_transitions(true)  # Enable blur transitions
	set_blur_duration(2.0)  # Longer blur for dramatic effect
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	scene_text.text = encounter_text
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text
	
	# Hide buttons initially - they'll show after typewriter effect
	left_button.visible = false
	right_button.visible = false
	
	# Start typewriter effect
	start_typewriter_effect(encounter_text)

func on_choice_selected(choice_index: int):
	"""Handle choice selection for end screen actions"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	
	if choice.has("action"):
		match choice.action:
			"restart_game":
				restart_game()
			"quit_game":
				quit_game()

func restart_game():
	"""Restart the entire game"""
	var story_manager = get_node("/root/Main/StoryManager")
	if story_manager:
		story_manager.restart_game()

func quit_game():
	"""Quit the application"""
	get_tree().quit()

func on_encounter_start():
	# End screen atmosphere - peaceful fade
	fade_background(1.0, 3.0)
	await get_tree().create_timer(1.5).timeout
	pulse_character(1.1, 4.0)  # Slow, peaceful pulse
