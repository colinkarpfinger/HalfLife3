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

var spawn_position = 0
var entered = false
var entered_duration = 0
var death_length = 1

var flicker_length = 0.2
var flicker_duration = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.set_animation(charger_colors[color])
	
func _process(delta): 
	if entered:
		entered_duration += delta
		flicker_duration += delta
		if flicker_duration > flicker_length:
			flicker_duration = 0
			self.visible = not self.visible
		if entered_duration > death_length:
			get_parent().change_position(self)
			entered = false
			self.visible = true
			entered_duration = 0
			flicker_duration = 0


func _on_Charger_body_entered(body):
	if body.name == 'Player':
		body.change_beam_color(color)
		entered = true
		#$AnimatedSprite.set_animation(color + '_death')
	
