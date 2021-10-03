extends Node2D
export var numToSpawn = 200
export var spawnVelocityMagnitude = 10
export var maxRotationSpeed = 2
export var particleScale = 1
export var spawn_distance = 15
export var spawn_time = 6

export var add_music_particle_threshold_1 = 5
export var add_music_particle_threshold_2 = 10
export var add_music_particle_threshold_3 = 20

const Particle = preload("res://Scripts/Particle.gd")

const sprites_large = {
	Particle.colors.RED: preload("res://Subscenes/Particles/Red.tscn"),
	Particle.colors.YELLOW: preload("res://Subscenes/Particles/Yellow.tscn"),
	Particle.colors.GREEN: preload("res://Subscenes/Particles/Green.tscn"),
}

const sprites_small = {
	Particle.colors.RED: preload("res://Subscenes/Particles/RedSmall.tscn"),
	Particle.colors.YELLOW: preload("res://Subscenes/Particles/YellowSmall.tscn"),
	Particle.colors.GREEN: preload("res://Subscenes/Particles/GreenSmall.tscn"),
}

var spawn_count = 0

## Audio
var basic_drums
var jam_bells
var percussive_ornaments
var snare_and_kick

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_audio()
	randomize()
	
	$Timer.wait_time = spawn_time

	var angle_delta = 360 / max(numToSpawn - 1, 1)
	for n in range(0, numToSpawn):
		spawn_in_center_at_angle(n * angle_delta)
		

func spawn_particle(position:Vector2, velocity:Vector2, mass:float, decay_level:int, color: int, state: int):
	var particle_type = sprites_large[color] if decay_level <= 2 else sprites_small[color]
	var particle = particle_type.instance()
	particle.color = color
	particle.decayLevel = decay_level
	add_child(particle)
	particle.set_position(position)
	particle.linear_velocity = velocity
	particle.mass = mass
	particle.state = state
#	particle.spawnTime = OS.get_ticks_msec()
	return particle
	
const center = Vector2(512, 300)

func spawn_in_center_at_angle(degrees: float):
	var initialVelocity = Vector2(spawnVelocityMagnitude, 0)
	
	initialVelocity = initialVelocity.rotated(degrees)
	var offset = Vector2(spawn_distance, 0).rotated(degrees)
	var particle = spawn_particle(center + offset, initialVelocity, 1, 1, randi() % 3, Particle.states.INACTIVE)
	var randomRotationDirection =  1 if rand_range(-1,1) > 0 else -1
	particle.angular_velocity = maxRotationSpeed
	
func _on_Timer_timeout():

	var randomRotationDegrees = rand_range(0,360)
	spawn_in_center_at_angle(randomRotationDegrees)
	spawn_count += 1
	maybe_play_audio()


func maybe_play_audio():
	if spawn_count >= add_music_particle_threshold_1:
		basic_drums.volume_db = 0
		
	if spawn_count >= add_music_particle_threshold_2:
		snare_and_kick.volume_db = 0
		
	if spawn_count >= add_music_particle_threshold_3:
		percussive_ornaments.volume_db = 0

func setup_audio():
	basic_drums = get_node("basic_drums")
	jam_bells = get_node("jam_bells")
	percussive_ornaments = get_node("percussive_ornaments")
	snare_and_kick = get_node("snare_and_kick")
	
	jam_bells.volume_db = 0 # play from start
	basic_drums.volume_db = -80
	percussive_ornaments.volume_db = -80
	snare_and_kick.volume_db = -80
