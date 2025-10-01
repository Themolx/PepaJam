extends BaseEncounter

# Story data for this encounter
var encounter_title = "An Unlikely Guide"
var encounter_text = "Došel rum, co teď?"

var encounter_choices = [
	{
		"text": "Vodka.",
		"next_scene": "res://encounters/Finnish/lavicka_ending.tscn",
		"effects": {
			"unlock_paths": ["artistic_path"]
		}
	},
	{
		"text": "Jdi zas dál.",
		"next_scene": "res://encounters/Akt2/Florenc/florenc_encounter.tscn"
	}
]


func on_encounter_start():
	# Fade in when encounter starts
	#fade_in()
	pass

func on_choice_selected(choice_index: int):
	"""Handle choice selection with effects and next scene loading"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	
	if choice_index == 0:
		$AnimatedSprite2D3.show()
		$AnimatedSprite2D3.play()
		await get_tree().create_timer(1.2).timeout
	
	# Process effects if they exist
	if choice.has("effects"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.process_effects(choice.effects)
	
	# Load next scene
	if choice.has("next_scene"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			fade_out_and_load_scene(choice.next_scene)

func _ready():
	encounter_id = "pub_exit"

	set_typewriter_mode("letter")  # or "word"
	set_typewriter_speed(0.03)  # Faster typing for drunk stumbling effect
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text
	
	# Use the new dialogue system for better text handling
	set_encounter_text(encounter_text)


func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer2.play()
	$VideoStreamPlayer.hide()
