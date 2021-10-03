extends RigidBody2D

class_name Particle


export (float) var collisionSpeedUp = 1
export (float) var slowedDamp = 2
export (float) var max_speed = 1000
var slowed = false
var decayLevel = 1
var decayLevelMax = 3
var absoluteScale = 1
var decayOffset = 80

var numParticlesOnDecay = 2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
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
	if rand_range(0, 10 / _delta) <= 1:
		decay()
	linear_velocity = linear_velocity.clamped(max_speed)



func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)



func decay():
	
	print("Particle: Decayed to: " + str(decayLevel))
	
	setScale(0.5)
	
	var base_offset = linear_velocity.normalized() * decayOffset
	
	var angle_delta = 2 * PI / numParticlesOnDecay
	print(angle_delta)
	if decayLevel <= decayLevelMax:
		for i in range(0, numParticlesOnDecay):
			var new_angle = angle_delta * i + linear_velocity.angle()
			var offset = base_offset.normalized().rotated(new_angle) * scale
			var new_velocity = linear_velocity.length() * Vector2.RIGHT.rotated(new_angle)
			print(new_angle, '      ', new_velocity.angle())
			print("Particle: spawning with scale: " + str(absoluteScale))
			var particle = get_parent().call_deferred(
				"spawn_at_position_with_velocity_mass_scale",
				position + offset,
				new_velocity,
				mass,
				absoluteScale,
				decayLevel + 1
			)
	queue_free()

func _slow():
	slowed = true

