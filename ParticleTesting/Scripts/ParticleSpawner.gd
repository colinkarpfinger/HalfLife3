extends Node2D
export var numToSpawn = 200
export var spawnVelocityMagnitude = 50
export var maxRotationSpeed = 2
export var particleScale = 1

const Particle = preload("res://Subscenes/Particle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for n in numToSpawn:
		randomize()
		
		var xPos = rand_range(0, get_viewport().size.x)
		var yPos = rand_range(0, get_viewport().size.y)
		
		var initialVelocity = Vector2(spawnVelocityMagnitude,0)
		var randomRotationDegrees = rand_range(0,360)
		initialVelocity = initialVelocity.rotated(randomRotationDegrees)
					
		var particle = spawn_at_position_with_velocity_mass_scale(Vector2(xPos,yPos), initialVelocity, 1, particleScale, 1)
		var particleTyped : Particle = particle
		particleTyped.setScale(particleScale)

		var randomRotationDirection =  1 if rand_range(-1,1) > 0 else -1
						
		
		#particle.apply_torque_impulse(maxRotationSpeed * randomRotationDirection)
		particle.angular_velocity = maxRotationSpeed
		
	

func spawn_at_position_with_velocity_mass_scale(position:Vector2, velocity:Vector2, mass:float, _scale:float, decay_level:int):
	var particle = Particle.instance()
	add_child(particle)
	particle.set_position(position)
	particle.linear_velocity = velocity
	particle.mass = mass
	particle.decayLevel = decay_level
	particle.setScale(_scale)
	return particle




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
