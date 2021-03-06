extends RigidBody2D

class_name Particle

signal collided

var animatedSprite = null
var sprite = null

#export (float) var collisionSpeedUp = 50
export (float) var slowedDamp = 2
export (float) var max_speed = 1000
export (float) var max_speed_for_audio = 200
export (float) var startingHealth = 600
export (int) var numParticlesOnDecay = 2
export (float) var shakeAmount = 4
export (float) var shakeVecDecayFactor = 0.5
export (float) var accelMultiplier = 1
export (float) var wrongColorDamageReduce = .3
export (float) var childSpawnAccel = 1
export (float) var msTillAccelIncrease = 20000
export (float) var accelIncreaseBy = .005



onready var RNG = RandomNumberGenerator.new()
var spawnTime = 0
var slowed = false
var decayLevel = 1
var decayLevelMax = 4
var absoluteScale = 1
var decayOffset = 80
var emittingParticles = false
var gradualAccel = .05
var sceneLoadTime = 0

var health : float = startingHealth
var shakeVec : Vector2 = Vector2(0, 0)

signal particle_fully_decayed

onready var burstSprite = load("res://Subscenes/Burst.tscn")

enum colors {RED, YELLOW, GREEN}

enum states {ACTIVE, INACTIVE}

var state = states.INACTIVE
var color = colors.RED


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
var popSounds = [ 
	preload("res://Audio/Effects/BALLOON_Pop_Real_01_mono.wav"), 
	preload("res://Audio/Effects/BALLOON_Pop_Real_02_mono.wav"), 
	preload("res://Audio/Effects/BALLOON_Pop_Real_03_mono.wav"), 
	preload("res://Audio/Effects/BALLOON_Pop_Real_04_mono.wav"), 
	preload("res://Audio/Effects/BALLOON_Pop_Deep_01_mono.wav"), 
	preload("res://Audio/Effects/BALLOON_Pop_Deep_02_mono.wav") ]
	
var popSounds2 = [
	preload("res://Audio/Effects/wobble_3_var_0.wav"),
	preload("res://Audio/Effects/wobble_3_var_1.wav"),
	preload("res://Audio/Effects/wobble_3_var_2.wav"),
	preload("res://Audio/Effects/wobble_3_var_3.wav")
	]
	
# -----------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	sceneLoadTime = get_node("../../../Main").sceneLoadTime
	$CPUParticles2D.emitting = false
	startingHealth *= globalScales[decayLevel - 1] * rand_range(.9, 1.1)
	health = startingHealth
	RNG.randomize()
	animatedSprite = get_node("Sprites/AnimatedSprite")
	sprite = get_node("Sprites/Sprite")
	setScale(spriteScales[decayLevel - 1])
	pass



func _process(_delta):
	if state == states.ACTIVE:
		modulate.a = 1
		if decayLevel < 4: 
			health -= 1 
		var healthFracCompl = 1 - max(0, health/startingHealth)
		var healthFracCompl2 = healthFracCompl*healthFracCompl
		var shakeScale = globalScales[decayLevel - 1]
		var shakeMag = healthFracCompl2*shakeAmount*shakeScale
		var x_shake = RNG.randfn(0, shakeMag)
		var y_shake = RNG.randfn(0, shakeMag)
		var shakeVecIncrement = Vector2(x_shake, y_shake)
		var oldShakeVec = shakeVec
		shakeVec = (oldShakeVec * shakeVecDecayFactor) + shakeVecIncrement
		animatedSprite.offset = shakeVec
		sprite.offset = shakeVec
	if state == states.INACTIVE:
		if OS.get_ticks_msec() % 500 < 250:
			modulate.a = .25
		else:
			modulate.a = 1



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
		angular_damp = 0
	
	if emittingParticles:
		$CPUParticles2D.emitting = true
		emittingParticles = false
	else:
		$CPUParticles2D.emitting = false
	
	if state == states.ACTIVE and health <= 0:  #and rand_range(0, 100 / _delta) <= 1:
		decay()
	var timeSinceLoad = OS.get_ticks_msec() - sceneLoadTime
	var accelAdded = accelIncreaseBy * floor(timeSinceLoad / msTillAccelIncrease) + gradualAccel
	linear_velocity += linear_velocity.normalized() * (accelAdded) * accelMultiplier
	linear_velocity = linear_velocity.clamped(max_speed)



func _on_Particle_body_exited(body):
	if body is RigidBody2D : 
		var bodyRB : RigidBody2D = body
		var velocityDirection = bodyRB.linear_velocity.normalized()
#		bodyRB.apply_impulse(Vector2(0,0), velocityDirection * collisionSpeedUp)
		
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


func playPopAudio():
	#$CollisionAudio.stop()
	$CollisionAudio.seek(0)
	$CollisionAudio.volume_db = -4
	var soundIndex = RNG.randi_range(0, popSounds2.size()-1) 
	$CollisionAudio.stream = popSounds2[soundIndex]
	$CollisionAudio.play()


func decay():
	var base_offset = linear_velocity.normalized() * decayOffset
	
	var angle_delta = 2 * PI / numParticlesOnDecay
	var angle_rnd_offset = RNG.randfn(0, 2*PI)
	if decayLevel < decayLevelMax:
		for i in range(0, numParticlesOnDecay):
			var new_angle = angle_delta * i + linear_velocity.angle() + angle_rnd_offset
			var offset = base_offset.normalized().rotated(new_angle) * scale
			var new_velocity = linear_velocity.length() * Vector2.RIGHT.rotated(new_angle) * childSpawnAccel
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
	
	else:
		emit_signal("particle_fully_decayed")
		playPopAudio()
		$CollisionAudio.connect("finished",self,"destroyRootParticle")
		$Collider.disabled = true
		if $Collider2:
			$Collider2.disabled = true
		$Sprites.visible = false
		state = states.INACTIVE
		spawn_burst_vfx(self.global_position)
		
		
func destroyRootParticle():
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
			emittingParticles = true
			health -= beamStrength / globalScales[decayLevel - 1]
		else:
			health -= beamStrength / globalScales[decayLevel - 1] * wrongColorDamageReduce
			
		slowed = true

