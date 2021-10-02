extends Area2D

var linearDamp = 2
var angularDamp = 2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Slow_Zone_body_entered(body):
	if body.is_in_group("Particle"):
		var particle : RigidBody2D = body
		particle.linear_damp = linearDamp;
		particle.angular_damp = angularDamp;


func _on_Slow_Zone_body_exited(body):
	if body.is_in_group("Particle"):
		var particle : RigidBody2D = body
		particle.linear_damp = 0;
		particle.angular_damp = 0;
