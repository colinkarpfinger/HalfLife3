extends Node2D

const Charger = preload("res://Subscenes/Charger.tscn")

const offset = 100

var spawns = null

var occupied = [0, 0, 0, 0]
# Called when the node enters the scene tree for the first time.
func _ready():
	var dimensions = get_viewport().size
	spawns = [
		Vector2(offset, offset),
		Vector2(offset, dimensions.y - offset),
		Vector2(dimensions.x - offset, offset),
		Vector2(dimensions.x - offset, dimensions.y - offset)
	]
	
	# Should be able to finish this fairly easily but I'm tired sorry lol
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
