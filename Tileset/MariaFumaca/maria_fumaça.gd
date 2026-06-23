extends Node2D
class_name Train

@onready var animationTrain:AnimatedSprite2D = $AnimatedSprite2D
@onready var animationSteam:AnimatedSprite2D = $AnimatedSprite2D2
@onready var steamTimer:Timer = $SteamTimer

@export var speed: float = 70.0
@export var direction: Vector2 = Vector2.LEFT
@export var destroy_x: float = -270.0


func _ready() -> void:
	steamTimer.start()


func _process(delta: float) -> void:
	if not animationTrain.is_playing():
		animationTrain.play("default")
	
	position += direction * speed * delta
	if position.x < destroy_x:
		queue_free()


func _on_steam_timer_timeout() -> void:
	animationSteam.play("default")
