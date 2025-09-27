extends BaseEncounter

# Story data for this encounter
var encounter_title = "Skin03"
var dialogue = [
		"Seš ňák vtipnej ne?",
		"Debile"
	]

var encounter_choices = [
	{
		"text": "Ajaj",
		"next_scene": "res://encounters/Finnish/trashcan_ending.tscn",
		"effects": {
			"unlock_paths": ["brave_path"],
			"set_flags": {"investigated_bush": true}
		}
	},
	{
		"text": "POMOC",
		"next_scene": "res://encounters/Finnish/trashcan_ending.tscn",
		"effects": {
			"set_flags": {"ignored_bush": true}
		}
	}
]

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

	call_deferred("set_encounter_text", dialogue)

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
	
	# Load next scene with fade transition
	if choice.has("next_scene"):
		fade_out_and_load_scene(choice.next_scene, 1.5)

func on_encounter_start():
	# Fade in when encounter starts
	fade_in()
	pass


func _on_video_stream_player_2_finished() -> void:
	$VideoStreamPlayer2.hide()
	$VideoStreamPlayer.play()
	pass # Replace with function body.
