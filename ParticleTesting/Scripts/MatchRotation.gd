extends Sprite

var mamaSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	mamaSprite = get_parent().get_node("AnimatedSprite")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotation_degrees = mamaSprite.rotation_degrees
