extends Area2D

export var color = Particle.colors.RED

const charger_colors = {
	Particle.colors.RED: "red",
	Particle.colors.GREEN: "green",
	Particle.colors.YELLOW: "yellow",
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var entered = false
var entered_duration = 0
var death_length = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.set_animation(charger_colors[color])
	
func _process(delta): 
	if entered:
		entered_duration += delta
#		if entered_duration > death_length:
#			get_parent().remove_child(self)
#			queue_free()




func _on_Charger_body_entered(body):
	if body.name == 'Player':
		body.change_beam_color(color)
		entered = true
		#$AnimatedSprite.set_animation(color + '_death')
	
