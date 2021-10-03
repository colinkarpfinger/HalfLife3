extends Node2D

const Particle = preload("res://Scripts/Particle.gd")

const open_length = 2
const closed_length = 8

var walls_open = false

var state_duration  = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	update_walls_open(walls_open)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state_duration += delta
	
	if walls_open and state_duration > open_length:
		walls_open = false
		state_duration = 0
		update_walls_open(walls_open)
	elif not walls_open and state_duration > closed_length:
		walls_open = true
		state_duration = 0
		update_walls_open(walls_open)
	

		
		


func update_walls_open(walls_opened: bool):
	if walls_open:
		$WallSprite.set_modulate(Color(1, 1, 1, 0.5))
		$WallSprite.set_animation('open')
	else:
		$WallSprite.set_modulate(Color(1, 1, 1, 1))
		$WallSprite.set_animation('closed')
	$Walls/Left/Collider.one_way_collision = walls_opened
	$Walls/Right/Collider.one_way_collision = walls_opened
	$Walls/Top/Collider.one_way_collision = walls_opened
	$Walls/Bottom/Collider.one_way_collision = walls_opened
	


func _on_Area2D_body_exited(body):
	if body.is_in_group("Particle"):
		body.state = Particle.states.ACTIVE
