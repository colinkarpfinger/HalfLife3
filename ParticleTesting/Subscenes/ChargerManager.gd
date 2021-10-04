extends Node2D

const Charger = preload("res://Subscenes/Charger.tscn")

const offset = 100

var spawns = null

var occupied = [1, 1, 1, 0]
# Called when the node enters the scene tree for the first time.
func _ready():
	var dimensions = get_viewport().size
	print(dimensions)

	spawns = [
		Vector2(offset, offset),
		Vector2(offset, dimensions.y - offset),
		Vector2(dimensions.x - 2 * offset, offset),
		Vector2(dimensions.x - 2 * offset, dimensions.y - offset)
	]
	randomize()
	spawns.shuffle()
	
	var red = Charger.instance()
	red.color = Particle.colors.RED
	red.spawn_position = 0
	add_child(red)
	red.position = spawns[0]
	
	var green = Charger.instance()
	green.color = Particle.colors.GREEN
	green.spawn_position = 1
	add_child(green)
	green.position = spawns[1]
	
	var yellow = Charger.instance()
	yellow.color = Particle.colors.YELLOW
	yellow.spawn_position = 2
	add_child(yellow)
	yellow.position = spawns[2]


func change_position(charger):
	var new_position = 0
	for i in range(0, len(occupied)):
		if occupied[i] == 0:
			new_position = i
	occupied[charger.spawn_position] = 0
	charger.spawn_position = new_position
	occupied[charger.spawn_position] = 1
	charger.set_position(spawns[new_position])
	
	
