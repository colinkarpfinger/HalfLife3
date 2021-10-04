extends KinematicBody2D

signal player_hit
signal player_died

export var beamPath := NodePath();
onready var beam : Beam = get_node(beamPath);

export (float) var accel_speed = 20
export (float) var max_speed = 1000
export (float) var drag = 5
export (float) var min_speed = 25
export (float) var aim_lerp = .2
export (float) var idleAnimCutoff = 75
export (float) var animFramerate = 10
export (float) var hitBump = 300
export (int) var hitAnimLength = 30
export (int) var invincibleLength = 30

var health = 5
var hitAnim = 0
var velocity = Vector2()
var state = player_states.NORMAL

enum player_states{NORMAL, HIT, INVINCIBLE}

func _process(_delta):
	#update run/idle animation
	if velocity.length() > idleAnimCutoff :
		$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.speed_scale = velocity.length()/max_speed * animFramerate
	else:
		$AnimatedSprite.play("default")
	#flash if hit
	if state == player_states.HIT || state == player_states.INVINCIBLE:
		self.visible = hitAnim % 10 < 6
	#update state
	if hitAnim > 0:
		hitAnim -= 1
		if hitAnim == invincibleLength:
			state = player_states.INVINCIBLE
		if hitAnim == 0:
			state == player_states.NORMAL


func _physics_process(_delta):
	#get input
	var input = get_input(_delta)
	#update beam position
	var mouse_vec = get_local_mouse_position()
#	beam.rotation = lerp_angle(beam.rotation, mouse_vec.angle() + PI/2, aim_lerp)
#	beam.transform.origin = Vector2(cos(beam.rotation - PI/2), sin(beam.rotation - PI/2)) * 180
	var beamAnchor = $BeamAnchor
	beamAnchor.rotation = lerp_angle(beamAnchor.rotation, mouse_vec.angle() + PI/2, aim_lerp)
#	beamAnchor.transform.origin = Vector2(cos(beamAnchor.rotation - PI/2), sin(beamAnchor.rotation - PI/2)) * 180
	#add input to velocity
	if state == player_states.NORMAL || state == player_states.INVINCIBLE:	
		velocity += input.normalized() * accel_speed
		velocity = velocity.clamped(max_speed)
		if input.length() == 0:
			velocity = lerp(velocity, Vector2.ZERO, drag * .01)
			if velocity.length() < min_speed:
				velocity = Vector2.ZERO
	#move player
	velocity = move_and_slide(velocity)


func get_input(delta) -> Vector2:
	var input = Vector2.ZERO
	if Input.is_action_pressed("move_left") : input.x -= 1
	if Input.is_action_pressed("move_right") : input.x += 1
	if Input.is_action_pressed("move_up") : input.y -= 1
	if Input.is_action_pressed("move_down") : input.y += 1
	if  not Input.is_action_pressed("fire") : 
		beam.doFreeze(delta)
		beam.visible = true;
	else:
		beam.visible = false;
	return input
	

#hit by bullet
func _on_Area2D_body_entered(body):
	if hitAnim == 0 && body.is_in_group("Particle") :
		health -= 1
		if health == 0: 
			die()
		#update state
		hitAnim += hitAnimLength + invincibleLength
		state = player_states.HIT
		#add velocity from hit
		velocity = - (body.transform.origin - transform.origin).normalized() * hitBump
		#signal to heart meter
		emit_signal("player_hit", health)

#health reached 0
func die():
	get_tree().queue_delete(self)
	emit_signal("player_died")

func change_beam_color(new_color):
	beam.change_color(new_color)
	
#math helper functions
static func lerp_angle(from, to, weight):
	return from + _short_angle_dist(from, to) * weight

static func _short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
