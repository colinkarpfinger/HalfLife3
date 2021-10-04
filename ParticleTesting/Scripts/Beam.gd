class_name Beam

extends Area2D


export (float) var beamStrength = 300
export (int) var color = Particle.colors.YELLOW

const beam_colors = {
	Particle.colors.RED: "red",
	Particle.colors.GREEN: "green",
	Particle.colors.YELLOW: "yellow",
}

func _ready():
	$AnimatedSprite.set_animation(beam_colors[color])

func doFreeze(delta):
	for body in get_overlapping_bodies() :
		if body.is_in_group("Particle"):
			var particle : Particle = body
			particle._slow(beamStrength * delta, color)


func change_color(new_color):
	color = new_color
	$AnimatedSprite.set_animation(beam_colors[new_color])
