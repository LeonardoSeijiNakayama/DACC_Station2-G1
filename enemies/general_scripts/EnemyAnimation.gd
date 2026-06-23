extends Node
class_name EnemyAnimation

@onready var _enemy:CharacterBody2D = get_parent()
@onready var _animation:AnimatedSprite2D = $"../AnimatedSprite2D"

var animation_locked = false

func _physics_process(_delta: float) -> void:
	if not animation_locked:
		if _enemy.velocity.x != 0.0:
			_animation.play("Walking")
		else:
			_animation.play(("Idle"))

func play_attack_animation()->void:
	_animation.play(("Attack"))
	animation_locked = true
	pass

func _on_animated_sprite_2d_animation_finished() -> void:
	if _animation.animation == "Attack":
		animation_locked = false
