class_name Particle

extends KinematicBody2D

export (float) var speed = 100
export (float) var max_speed = 600
export (float) var bounce_multiplier = 1.05
export (float) var stable_speed = 50
export (float) var stable_length = 5000

var is_stable = false 
var timeScale = 1.0
var stable_since_frame = 0;

var direction = Vector2()

func _ready():
	direction = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
	pass

func _process(_delta):
	pass
	
func multiplySpeed(other_spd):
	var higher_speed = max(other_spd, speed)
	speed = bounce_multiplier * higher_speed
	return speed

func _physics_process(_delta):
	speed = min(speed, max_speed)
	if speed < stable_speed:
		if not is_stable:
			is_stable = true
			stable_since_frame = OS.get_ticks_msec()
		else:
			if OS.get_ticks_msec() - stable_since_frame > stable_length:
#				get_tree().queue_delete(self)
				pass
	else:
		is_stable = false
	var coll = move_and_collide(direction * _delta * speed, true, true, false)
	if coll:
		direction = direction.bounce(coll.normal)
		if coll.collider.is_in_group("BouncyParticles"):
#			speed *= bounce_multiplier
			speed = coll.collider.multiplySpeed(speed)
