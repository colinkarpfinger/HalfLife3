extends RigidBody2D

class_name Particle


export (float) var collisionSpeedUp = 1
export (float) var slowedDamp = 2
export (float) var max_speed = 1000
export (float) var start_scale = 1
var slowed = false
var decayLevel = 1
var decayLevelMax = 4
var absoluteScale = 1
var decayOffset = 80
var numParticlesOnDecay = 2

enum colors {RED, YELLOW, GREEN}

var color = colors.RED
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const scales = [0.5, 0.35, 0.75, 0.5]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	setScale(scales[decayLevel - 1])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func setScale(_scale):
	absoluteScale *= _scale
	$Sprites.scale *=  _scale
	$Collider.scale *= _scale
	if color == colors.GREEN:
		$Collider2.scale *= _scale

func _physics_process(_delta):
	if slowed: 
		linear_damp = slowedDamp
		slowed = false
	else: 
		linear_damp = 0
	if rand_range(0, 100 / _delta) <= 1:
		decay()
	linear_velocity = linear_velocity.clamped(max_speed)



func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)



func decay():
	
	var base_offset = linear_velocity.normalized() * decayOffset
	
	var angle_delta = 2 * PI / numParticlesOnDecay
	if decayLevel <= decayLevelMax:
		for i in range(0, numParticlesOnDecay):
			var new_angle = angle_delta * i + linear_velocity.angle()
			var offset = base_offset.normalized().rotated(new_angle) * scale
			var new_velocity = linear_velocity.length() * Vector2.RIGHT.rotated(new_angle)
			#print(new_angle, '      ', new_velocity.angle())
			#print("Particle: spawning with scale: " + str(absoluteScale))
			var particle = get_parent().call_deferred(
				"spawn_particle",
				position + offset,
				new_velocity,
				mass,
				decayLevel + 1,
				color
			)
	queue_free()

func _slow():
	slowed = true

