extends RigidBody2D

class_name Particle

var animatedSprite = null
var sprite = null

export (float) var collisionSpeedUp = 50
export (float) var slowedDamp = 2
export (float) var max_speed = 1000
export (float) var max_speed_for_audio = 200
export (float) var start_scale = 1
export (int) var startingHealth = 600
export (float) var shakeAmount = 4
export (float) var shakeVecDecayFactor = 0.5

onready var RNG = RandomNumberGenerator.new()
var spawnTime = 0
var slowed = false
var decayLevel = 1
var decayLevelMax = 4
var absoluteScale = 1
var decayOffset = 80
var numParticlesOnDecay = 2
var health = startingHealth
var shakeVec : Vector2 = Vector2(0, 0)

onready var burstSprite = load("res://Subscenes/Burst.tscn")

enum colors {RED, YELLOW, GREEN}

enum states {ACTIVE, INACTIVE}

var state = states.INACTIVE
var color = colors.RED
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const spriteScales = [0.5, 0.35, 0.75, 0.5]
const globalScales = [1.0, 0.75, 0.5, 0.25]
const audioScales = [1.0, 0.5625, 0.25, 0.0625]

# -----------------------------------------------------------------------------
# Audio
var sounds = [
	[
		preload("res://Audio/Effects/wobble_0_var_0.wav"),
		preload("res://Audio/Effects/wobble_0_var_1.wav"),
		preload("res://Audio/Effects/wobble_0_var_2.wav"),
		preload("res://Audio/Effects/wobble_0_var_3.wav")
	], [
		preload("res://Audio/Effects/wobble_1_var_0.wav"),
		preload("res://Audio/Effects/wobble_1_var_1.wav"),
		preload("res://Audio/Effects/wobble_1_var_2.wav"),
		preload("res://Audio/Effects/wobble_1_var_3.wav")
	], [
		preload("res://Audio/Effects/wobble_2_var_0.wav"),
		preload("res://Audio/Effects/wobble_2_var_1.wav"),
		preload("res://Audio/Effects/wobble_2_var_2.wav"),
		preload("res://Audio/Effects/wobble_2_var_3.wav")
	], [
		preload("res://Audio/Effects/wobble_3_var_0.wav"),
		preload("res://Audio/Effects/wobble_3_var_1.wav"),
		preload("res://Audio/Effects/wobble_3_var_2.wav"),
		preload("res://Audio/Effects/wobble_3_var_3.wav")
	]
]

# -----------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
#	health *= globalScales[decayLevel - 1]
	RNG.randomize()
	animatedSprite = get_node("Sprites/AnimatedSprite")
	sprite = get_node("Sprites/Sprite")
	setScale(spriteScales[decayLevel - 1])
	pass



func _process(_delta):
	if state == states.ACTIVE && decayLevel < 4: 
		health -= 1 
	var healthFracCompl = 1 - max(0, health/startingHealth)
	var healthFracCompl2 = healthFracCompl*healthFracCompl
	var shakeScale = globalScales[decayLevel - 1]
	var shakeMag = healthFracCompl2*shakeAmount*shakeScale
	var x_shake = RNG.randfn(0, shakeMag)
	var y_shake = RNG.randfn(0, shakeMag)
	var shakeVecIncrement = Vector2(x_shake, y_shake)
	var oldShakeVec = shakeVec
	var shakeVec = (oldShakeVec * shakeVecDecayFactor) + shakeVecIncrement
	animatedSprite.offset = shakeVec
	sprite.offset = shakeVec



func setScale(_scale):
	absoluteScale *= _scale
	$Sprites.scale *=  _scale
	$Collider.scale *= _scale
	if color == colors.GREEN:
		$Collider2.scale *= _scale

func _physics_process(_delta):
	if slowed: 
		linear_damp = slowedDamp
		angular_damp = slowedDamp
		slowed = false
	else: 
		linear_damp = 0
		angular_damp = slowedDamp
	
	if state == states.ACTIVE and health <= 0:  #and rand_range(0, 100 / _delta) <= 1:
		decay()
	linear_velocity = linear_velocity.clamped(max_speed)



func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)
		
	var selfRB : RigidBody2D = self
	
	var speedFrac = 0
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var relativeSpeed = (selfRB.linear_velocity - bodyRB.linear_velocity).length()
		speedFrac = relativeSpeed / (2*max_speed_for_audio)
	else:
		speedFrac = selfRB.linear_velocity.length() / max_speed_for_audio
		
	var gain = audioScales[decayLevel-1]
		
	playCollisionAudio(speedFrac, gain)

func playCollisionAudio(rawSpeedFrac: float, rawGain: float):
	var playbackPosition = $CollisionAudio.get_playback_position()
	if playbackPosition == 0 or playbackPosition > 0.1:
		var speedFrac = min(1, max(0, rawSpeedFrac)) # bounding for safety
		if speedFrac > 0.01: # avoid playing any sound for really light collisions
			# collision energy proportional to square of relative velocity
			var speedFracSq = speedFrac*speedFrac
			var gain = min(1, max(0, rawGain))
			$CollisionAudio.volume_db = log(gain * speedFracSq) - 6
			
			var soundIndex = RNG.randi_range(0, sounds.size()-1) 
			$CollisionAudio.stream = sounds[decayLevel-1][soundIndex]
			
			$CollisionAudio.play()



func decay():
	
	var base_offset = linear_velocity.normalized() * decayOffset
	
	var angle_delta = 2 * PI / numParticlesOnDecay
	if decayLevel < decayLevelMax:
		for i in range(0, numParticlesOnDecay):
			var new_angle = angle_delta * i + linear_velocity.angle()
			var offset = base_offset.normalized().rotated(new_angle) * scale
			var new_velocity = linear_velocity.length() * Vector2.RIGHT.rotated(new_angle)
			#print(new_angle, '      ', new_velocity.angle())
			#print("Particle: spawning with scale: " + str(absoluteScale))
			var particle = get_parent().call_deferred(
				"spawn_particle",
				position + offset,
				new_velocity,
				mass,
				decayLevel + 1,
				color,
				states.ACTIVE
			)
	spawn_burst_vfx(self.global_position)
	queue_free()

func spawn_burst_vfx(pos):
	var burst = burstSprite.instance()
	burst.global_position = pos
	burst.rotation_degrees = RNG.randf_range(0, 360)
	get_tree().get_root().add_child(burst)
	pass

func _slow(beamStrength, beamColor):
	if state == states.ACTIVE:
		if beamColor == color:
			health -= beamStrength / globalScales[decayLevel - 1]
		slowed = true

