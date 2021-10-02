extends RigidBody2D

class_name Particle

var collisionSpeedUp = 5


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)


func _on_Particle_body_entered(body):
	print("collided")
	var bodyRB : RigidBody2D = body
	var velocityDirection = bodyRB.linear_velocity.normalized()
	bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)
