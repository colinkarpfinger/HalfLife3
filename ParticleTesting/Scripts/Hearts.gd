extends Node2D

export (int) var heartsAmt = 5
export (float) var opacity = 0.5

const heart = preload("res://Images/heart.png")

func _ready():
	for i in range(heartsAmt):
		var heartSprite = Sprite.new();
		heartSprite.texture = heart
		heartSprite.transform.origin = Vector2( 20 + 35 * i, 20)
		heartSprite.modulate = Color(1, 1, 1, opacity)
		add_child(heartSprite)


func _on_Player_player_hit(health):
	get_child(health).visible = false
