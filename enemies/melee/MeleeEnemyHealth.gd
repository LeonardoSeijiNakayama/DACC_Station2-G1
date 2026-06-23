extends Node
class_name  MeleeEnemyHealth

@export var MAXIMUM_HEALTH = 100.0
@export var CURRENT_HEALTH = MAXIMUM_HEALTH
@onready var _enemy:CharacterBody2D = $".."

func _process(_delta: float) -> void:
	if CURRENT_HEALTH <= 0.0:
		get_parent().queue_free()


func take_damage(dmg:float)->void:
	CURRENT_HEALTH -= dmg
	if CURRENT_HEALTH <= 0.0:
		_enemy.queue_free()

func heal(quantity:float)->void:
	CURRENT_HEALTH += quantity
	if CURRENT_HEALTH > 100.0:
		CURRENT_HEALTH = 100.0
