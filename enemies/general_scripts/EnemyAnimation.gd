extends Node
class_name EnemyAnimation

@onready var _enemy: CharacterBody2D = get_parent()
@onready var _animation: AnimatedSprite2D = $"../AnimatedSprite2D"

var auxiliar_animation: AnimatedSprite2D = null
var auxiliar_animation2:AnimatedSprite2D = null
var animation_locked := false

var float_time := 0.0
var main_original_position: Vector2
var auxiliar_original_position: Vector2

@export var float_speed := 4.0
@export var float_strength := 3.0


func _ready() -> void:
	auxiliar_animation = get_parent().get_node_or_null("AuxiliarSprite") as AnimatedSprite2D
	auxiliar_animation2 = get_parent().get_node_or_null("AuxiliarSprite2") as AnimatedSprite2D
	
	main_original_position = _animation.position
	
	if auxiliar_animation != null:
		auxiliar_original_position = auxiliar_animation.position


func _physics_process(delta: float) -> void:
	if not animation_locked:
		if _enemy.velocity.x != 0.0:
			_animation.play("Walking")
			
			if auxiliar_animation != null:
				auxiliar_animation.play("Walking")
			if auxiliar_animation2 != null:
				auxiliar_animation2.play("Walking")
		else:
			_animation.play("Idle")
			
	
	if get_parent() is MeleeEnemy:
		_apply_auxiliar_float(delta)


func _apply_auxiliar_float(delta: float) -> void:
	float_time += delta
	
	var y_offset := sin(float_time * float_speed) * float_strength
	
	_animation.position = main_original_position + Vector2(0, y_offset)
	auxiliar_animation.position = auxiliar_original_position + Vector2(0, y_offset)


func play_attack_animation() -> void:
	_animation.play("Attack")
	animation_locked = true
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if _animation.animation == "Attack":
		animation_locked = false
