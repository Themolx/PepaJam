extends BaseEncounter
@export var new_scene: String = "res://encounters/Finnish/policie_ending.tscn"
# Pissing system variables
var is_pissing = false
var piss_timer = 0.0
var max_piss_time = 14.0
var droplet_particles: GPUParticles2D
var stream_line: Line2D
var start_position: Vector2
var end_position: Vector2
var mouse_position: Vector2

# Animation variables
var wiggle_time = 0.0
var wiggle_intensity = 1.5
var stream_width = 5.0
var max_stream_distance = 300.0
var arc_height = 80.0  # Height of the arc
var end_point_offset_time = 0.0
var end_point_offset_radius = 15.0

# Story data for this encounter
var encounter_title = "An Unlikely Guide"
var encounter_text = "Toje pohoda, chcát v sedě."

var encounter_choices = [
	{
		"text": "Dát cígo.",
		"next_scene": "res://encounters/Akt2/Dita/dita_encounter_01.tscn",
		"effects": {
			"unlock_paths": ["artistic_path"]
		}
	},
	{
		"text": "Sam nemam.",
		"next_scene": "res://encounters/Akt2/Dita/dita_encounter_01.tscn"
	}
]


func on_encounter_start():
	# Fade in when encounter starts
	fade_in()

func on_choice_selected(choice_index: int):
	"""Handle choice selection with effects and next scene loading"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	
	if choice_index == 0:
		$VideoStreamPlayerH.play()
		$VideoStreamPlayerH.show()
		await get_tree().create_timer(2).timeout
	else:
		$VideoStreamPlayerS.play()
		$VideoStreamPlayerS.show()
	await get_tree().create_timer(1.5).timeout
	
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

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text
	
	# Use the new dialogue system for better text handling
	set_encounter_text(encounter_text)


func _ready() -> void:
	encounter_id = "piss_encounter"
	setup_piss_system()


	set_typewriter_mode("letter")  # or "word"
	set_typewriter_speed(0.03)  # Faster typing for drunk stumbling effect
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()

func setup_piss_system():
	"""Initialize the pissing visual system"""
	# Set start position at bottom center of screen
	start_position = Vector2(184, 368)
	
	# Create simple line for stream
	stream_line = Line2D.new()
	add_child(stream_line)
	stream_line.width = stream_width
	stream_line.default_color = Color(0.774, 0.707, 0.234, 0.89)
	stream_line.visible = false
	
	# Create particle system for droplets at END of stream
	droplet_particles = GPUParticles2D.new()
	add_child(droplet_particles)
	droplet_particles.emitting = false
	
	# Configure droplet material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)  # Spray downward from end point
	particle_material.initial_velocity_min = -50.0
	particle_material.initial_velocity_max = -150.0
	particle_material.gravity = Vector3(0, 300, 0)  # Light gravity
	particle_material.scale_min = 0.3
	particle_material.scale_max = 0.8
	particle_material.lifetime_randomness = 0.5
	droplet_particles.process_material = particle_material
	droplet_particles.texture = create_droplet_texture()
	droplet_particles.lifetime = 0.5  # Short lifespan - few milliseconds
	droplet_particles.amount = 20
	
	# Start pissing immediately
	start_pissing()

func create_droplet_texture() -> ImageTexture:
	"""Create a simple yellow droplet texture"""
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.774, 0.707, 0.234, 0.89))
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func start_pissing():
	"""Begin the pissing sequence"""
	is_pissing = true
	piss_timer = 0.0
	droplet_particles.emitting = true
	stream_line.visible = true
	
	# Hide UI elements during pissing
	if left_button:
		left_button.visible = false
	if right_button:
		right_button.visible = false

func _process(delta):
	if is_pissing:
		piss_timer += delta
		wiggle_time += delta * 30.0  # Faster wiggle animation
		end_point_offset_time += delta * 5.0  # Speed of end point movement
		update_piss_stream()
		
		# Check if time is up
		if piss_timer >= max_piss_time:
			stop_pissing()

func update_piss_stream():
	"""Update the simple wiggling piss stream with arc and intensity curve"""
	mouse_position = get_global_mouse_position()
	
	# Calculate spray intensity with startup and ending phases
	var time_progress = piss_timer / max_piss_time
	var intensity_multiplier = 1.0
	
	if time_progress < 0.1:  # First 10% - ramp up from 0
		intensity_multiplier = time_progress / 0.1
	elif time_progress > 0.8:  # Last 20% - ramp down to 0
		var fade_progress = (time_progress - 0.8) / 0.2  # 0 to 1 over last 20%
		intensity_multiplier = 1.0 - fade_progress
	# Middle 70% stays at full intensity
	
	# Calculate end position based on mouse with intensity modulation
	var direction = ((mouse_position - Vector2(0, 180)) - start_position).normalized()
	var base_distance = min(((mouse_position - Vector2(0, 180)) - start_position).length(), max_stream_distance)
	var actual_distance = base_distance * intensity_multiplier
	var base_end_position = start_position + direction * actual_distance
	
	# Add circular offset to make end point move around
	var offset = Vector2(
		sin(end_point_offset_time) * end_point_offset_radius * intensity_multiplier,
		cos(end_point_offset_time * 1.3) * end_point_offset_radius * 0.7 * intensity_multiplier
	)
	end_position = base_end_position + offset
	
	# Create arced line with wiggle effect
	stream_line.clear_points()
	var num_points = 15  # More points for smoother arc
	
	for i in range(num_points + 1):
		var t = float(i) / float(num_points)
		var point = start_position.lerp(end_position, t)
		
		# Add parabolic arc (highest in middle)
		var arc_offset = -arc_height * sin(t * PI) * intensity_multiplier
		point.y += arc_offset
		
		# Add wiggle effect (more intense in middle of stream)
		var wiggle_strength = sin(t * PI) * wiggle_intensity * intensity_multiplier
		var wiggle_offset = Vector2(
			sin(wiggle_time + t * 3.0) * wiggle_strength,
			cos(wiggle_time * 1.5 + t * 2.0) * wiggle_strength * 0.5
		)
		
		stream_line.add_point(point + wiggle_offset)
	
	# Position droplet emitter at END of stream with reduced intensity
	var final_point = end_position
	final_point.y += -arc_height * sin(PI) * intensity_multiplier  # Account for arc
	droplet_particles.position = final_point
	
	# Reduce droplet amount as intensity decreases
	droplet_particles.amount = int(20 * intensity_multiplier)

func stop_pissing():
	"""End the pissing sequence and transition to next scene"""
	is_pissing = false
	droplet_particles.emitting = false
	stream_line.visible = false
	
	# Fade out effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# Load next scene (you can change this to whatever scene you want)
	fade_out_and_load_scene(new_scene)

func _input(event):
	"""Handle input for aiming the piss stream"""
	if is_pissing and (event is InputEventMouseMotion or event is InputEventScreenDrag):
		# Mouse position is automatically updated in _process
		pass
	
	# Don't call super._input() to prevent dialogue system interference


func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play()
	pass # Replace with function body.
