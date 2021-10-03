extends Node2D
export var numToSpawn = 200
export var spawnVelocityMagnitude = 10
export var maxRotationSpeed = 2
export var particleScale = 1
export var spawn_distance = 15
export var spawn_time = 6

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
# Called when the node enters the scene tree for the first time.
func _ready():
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
	return particle
	
const center = Vector2(512, 300)

func spawn_in_center_at_angle(degrees: float):
	var initialVelocity = Vector2(spawnVelocityMagnitude, 0)
	
	initialVelocity = initialVelocity.rotated(degrees)
	var offset = Vector2(spawn_distance, 0).rotated(degrees)
	var particle = spawn_particle(center + offset, initialVelocity, 1, 1, randi() % 3, 0)
	var randomRotationDirection =  1 if rand_range(-1,1) > 0 else -1
	particle.angular_velocity = maxRotationSpeed
	
func _on_Timer_timeout():

	var randomRotationDegrees = rand_range(0,360)
	spawn_in_center_at_angle(randomRotationDegrees)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

