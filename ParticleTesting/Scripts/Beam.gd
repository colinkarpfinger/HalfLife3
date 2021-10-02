class_name Beam

extends Area2D


func _ready():
	pass 

func doFreeze():
	for body in get_overlapping_bodies() :
		if body.is_in_group("Particle"):
			var particle : Particle = body
			particle._slow()
