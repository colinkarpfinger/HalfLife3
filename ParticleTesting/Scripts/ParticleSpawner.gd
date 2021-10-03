extends Node2D
export var numToSpawn = 200
export var spawnVelocityMagnitude = 50
export var maxRotationSpeed = 2
export var spawn_distance = 50
export var spawn_time = 2

const Particle = preload("res://Subscenes/Particle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	$Timer.wait_time = spawn_time

	var angle_delta = 360 / max(numToSpawn - 1, 1)
	for n in range(0, numToSpawn):
		spawn_in_center_at_angle(n * angle_delta)

					

	

func spawn_at_position_with_velocity(position:Vector2, velocity:Vector2):
	var particle = Particle.instance()
	add_child(particle)
	particle.set_position(position)
	particle.linear_velocity = velocity
	
	return particle
	
const center = Vector2(512, 300)

func spawn_in_center_at_angle(degrees: float):
	var initialVelocity = Vector2(spawnVelocityMagnitude, 0)
	
	initialVelocity = initialVelocity.rotated(degrees)
	var offset = Vector2(spawn_distance, 0).rotated(degrees)
	var particle = spawn_at_position_with_velocity(center + offset, initialVelocity)
	var randomRotationDirection =  1 if rand_range(-1,1) > 0 else -1
	particle.angular_velocity = maxRotationSpeed
	
func _on_Timer_timeout():

	var randomRotationDegrees = rand_range(0,360)
	spawn_in_center_at_angle(randomRotationDegrees)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

