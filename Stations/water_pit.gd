extends Node2D
class_name WaterPit


@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D


var outlined = false

func _process(_delta: float) -> void:
	if outlined:
		sprite.play("outlined")
	else:
		sprite.play("default")
