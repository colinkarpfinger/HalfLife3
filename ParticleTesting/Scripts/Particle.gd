extends RigidBody2D

class_name Particle


export (float) var collisionSpeedUp = 1
export (float) var slowedDamp = 2
var slowed = false
var decayLevel = 1
var decayLevelMax = 3
var absoluteScale = 1
var decayOffset = 80

var numParticlesOnDecay = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func setScale(_scale):
	absoluteScale *= _scale
	$AnimatedSprite.scale *=  _scale
	$CollisionShape2D.scale *=  _scale
	

func _physics_process(_delta):
	if slowed: 
		linear_damp = slowedDamp
		slowed = false
	else: 
		linear_damp = 0


func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)
		decay()


func decay():
	decayLevel += 1
	print("Particle: Decayed to: "+str(decayLevel))
	if decayLevel >= decayLevelMax:		#destroy ? 
		print("Particle: died")
		queue_free()	# queue destroy node
		return
	
	setScale(0.75)
	#mass *= 0.5
	
	for n in numParticlesOnDecay:
		randomize()
		var randAngle = rand_range(0,360)
		var offset = linear_velocity.normalized().rotated(90)*decayOffset*scale
		#var offset = Vector2(decayOffset, 0).rotated(randAngle)
		print("Particle: spawning with scale: "+str(absoluteScale))
		get_parent().call_deferred("spawn_at_position_with_velocity_mass_scale", position + offset, linear_velocity.rotated(10), mass, absoluteScale)
	
	
	
	



func _slow():
	slowed = true

