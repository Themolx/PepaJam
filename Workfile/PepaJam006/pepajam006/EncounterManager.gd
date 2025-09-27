extends Control
class_name EncounterManager

@onready var story_manager: StoryManager = $StoryManager
@onready var encounter_container: Control = $EncounterContainer
@onready var cutscene_player: VideoStreamPlayer = $CutscenePlayer
@onready var cutscene_overlay: ColorRect = $CutsceneOverlay
@onready var cutscene_text: Label = $CutsceneOverlay/CutsceneText

var current_encounter: BaseEncounter = null
var is_in_cutscene: bool = false

func _ready():
	setup_ui()
	connect_signals()
	# Start the story
	story_manager.restart_game()

func setup_ui():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Hide cutscene elements initially
	cutscene_player.visible = false
	cutscene_overlay.visible = false

func connect_signals():
	story_manager.encounter_load_requested.connect(_on_encounter_load_requested)
	story_manager.cutscene_triggered.connect(_on_cutscene_triggered)
	
	cutscene_player.finished.connect(_on_cutscene_finished)

func _on_encounter_load_requested(encounter_scene_path: String):
	if is_in_cutscene:
		return
	
	load_encounter_scene(encounter_scene_path)

func load_encounter_scene(scene_path: String):
	# Unload current encounter
	if current_encounter:
		current_encounter.on_encounter_end()
		current_encounter.queue_free()
		current_encounter = null
	
	# Load new encounter scene
	var encounter_scene = load(scene_path)
	if encounter_scene:
		current_encounter = encounter_scene.instantiate()
		encounter_container.add_child(current_encounter)
		
		# Connect encounter signals
		current_encounter.choice_made.connect(_on_encounter_choice_made)
		current_encounter.encounter_ready.connect(_on_encounter_ready)
		
		# Start the encounter (it will set up its own content)
		current_encounter.on_encounter_start()
	else:
		print("Failed to load encounter scene: ", scene_path)

func _on_encounter_choice_made(choice_index: int):
	if current_encounter and not is_in_cutscene:
		print("Choice made: ", choice_index)
		# The encounter will handle its own choice processing

func _on_encounter_ready():
	# Called when encounter entrance animation is complete
	pass

func _on_cutscene_triggered(cutscene_data: Dictionary):
	play_cutscene(cutscene_data)

func _on_act_completed(act_number: int):
	print("Act ", act_number, " completed!")

func play_cutscene(cutscene_data: Dictionary):
	is_in_cutscene = true
	
	# Hide current encounter
	if current_encounter:
		current_encounter.visible = false
	
	# Show cutscene elements
	cutscene_overlay.visible = true
	cutscene_text.text = cutscene_data.get("text", "")
	
	# Load and play video if available
	if cutscene_data.has("video"):
		var video_path = cutscene_data.video
		if FileAccess.file_exists(video_path):
			cutscene_player.visible = true
			# Note: You'll need to load the video stream here
			# var video_stream = load(video_path)
			# cutscene_player.stream = video_stream
			# cutscene_player.play()
		else:
			print("Cutscene video not found: ", video_path)
			# Skip to end of cutscene if video doesn't exist
			_on_cutscene_finished()
	else:
		# Text-only cutscene, auto-advance after delay
		await get_tree().create_timer(3.0).timeout
		_on_cutscene_finished()

func _on_cutscene_finished():
	is_in_cutscene = false
	
	# Hide cutscene elements
	cutscene_player.visible = false
	cutscene_overlay.visible = false
	
	# Show current encounter after cutscene
	if current_encounter:
		current_encounter.visible = true

func _input(event):
	# Allow skipping cutscenes with tap/click
	if is_in_cutscene and event is InputEventScreenTouch and event.pressed:
		if cutscene_player.visible and cutscene_player.is_playing():
			cutscene_player.stop()
		_on_cutscene_finished()

# Debug function to restart story
func restart_story():
	story_manager.restart_game()
