extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_up():
	$ScoreCounter.resetScore()
	get_tree().change_scene("res://Scenes/Main.tscn")
	pass # Replace with function body.


func _on_ParticleSpawner_particle_fully_decayed():
	$"ScoreCounter".incrementScore()


