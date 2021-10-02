extends Node2D
export var numToSpawn = 200
export var spawnVelocityMagnitude = 50
export var maxRotationSpeed = 2

const Particle = preload("res://Particle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for n in numToSpawn:
		randomize()
		
		var xPos = rand_range(0, get_viewport().size.x)
		var yPos = rand_range(0, get_viewport().size.y)
		
		var initialVelocity = Vector2(spawnVelocityMagnitude,0)
		var randomRotationDegrees = rand_range(0,360)
		initialVelocity = initialVelocity.rotated(randomRotationDegrees)
					
		var particle = spawn_at_position_with_velocity(Vector2(xPos,yPos), initialVelocity)
		
		var randomRotationDirection =  1 if rand_range(-1,1) > 0 else -1
						
		
		#particle.apply_torque_impulse(maxRotationSpeed * randomRotationDirection)
		particle.angular_velocity = maxRotationSpeed
		
	

func spawn_at_position_with_velocity(position:Vector2, velocity:Vector2):
	var particle = Particle.instance()
	add_child(particle)
	particle.set_position(position)
	particle.linear_velocity = velocity
	
	return particle
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
