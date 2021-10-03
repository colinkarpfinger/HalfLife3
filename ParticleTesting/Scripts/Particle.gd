extends RigidBody2D

class_name Particle

export (float) var collisionSpeedUp = 10
export (float) var slowedDamp = 2
export (float) var max_speed = 1000
var slowed = false


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	if slowed: 
		linear_damp = slowedDamp
		slowed = false
	else: 
		linear_damp = 0
	linear_velocity = linear_velocity.clamped(max_speed)


func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)


func _on_Particle_body_entered(body):
	var bodyRB : RigidBody2D = body
	var velocityDirection = bodyRB.linear_velocity.normalized()
	bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)

func _slow():
	slowed = true

