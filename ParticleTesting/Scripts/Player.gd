extends KinematicBody2D

signal player_hit

export (float) var accel_speed = 20
export (float) var max_speed = 1000
export (float) var drag = 5
export (float) var min_speed = 25
export (float) var aim_lerp = .2
export (float) var idleAnimCutoff = 75
export (float) var animFramerate = 10
export (float) var hitBump = 300
export (int) var hitAnimLength = 60

var health = 5
var hitAnim = 0

export var beamPath := NodePath();
onready var beam : Beam = get_node(beamPath);

var velocity = Vector2()

func _ready():
	pass 
	
func _process(_delta):
	if hitAnim > 0:
		hitAnim -= 1
		self.visible = hitAnim % 10 < 6

func _physics_process(_delta):

	var input = Vector2.ZERO
	
	if Input.is_action_pressed("move_left") : input.x -= 1
	if Input.is_action_pressed("move_right") : input.x += 1
	if Input.is_action_pressed("move_up") : input.y -= 1
	if Input.is_action_pressed("move_down") : input.y += 1
	
	if velocity.length() > idleAnimCutoff :
		$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.speed_scale = velocity.length()/max_speed * animFramerate
	else:
		$AnimatedSprite.play("default")
	
	if Input.is_action_pressed("fire") : 
		beam.doFreeze()
		beam.visible = true;
	else:
		beam.visible = false;
	
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_vec = (mouse_pos - transform.origin).normalized()
	var beam_rotation = mouse_vec.angle() + PI/2
	beam.rotation = lerp_angle(beam.rotation, beam_rotation, aim_lerp)
	beam.transform.origin = Vector2(cos(beam.rotation - PI/2), sin(beam.rotation - PI/2)) * 180
	
	if hitAnim < 30:	
		velocity += input.normalized() * accel_speed
		velocity = velocity.clamped(max_speed)
		
		if input.length() == 0:
			velocity = lerp(velocity, Vector2.ZERO, drag * .01)
			if velocity.length() < min_speed:
				velocity = Vector2.ZERO
				
	velocity = move_and_slide(velocity)

func die():
	get_tree().queue_delete(self)

func _on_Area2D_body_entered(body):
	if hitAnim == 0 && body.is_in_group("Particle") :
		health -= 1
		if health == 0: 
			die()
		hitAnim += hitAnimLength
		velocity = - (body.transform.origin - transform.origin).normalized() * hitBump
		emit_signal("player_hit", health)
		
static func lerp_angle(from, to, weight):
	return from + _short_angle_dist(from, to) * weight

static func _short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

