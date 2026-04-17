extends Node
class_name EnemyAnimation

@onready var _enemy:CharacterBody2D = get_parent()
@onready var _animation:AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var _attack = $"../Attack"

func _physics_process(_delta: float) -> void:
	if not _attack.attacking:
		if _enemy.velocity.x != 0.0:
			_animation.play("Walking")
		else:
			_animation.play(("Idle"))

func play_attack_animation()->void:
	_animation.play(("Attack"))
	pass
