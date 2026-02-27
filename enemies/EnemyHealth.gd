extends Node
class_name  EnemyHealth

@export var MAXIMUM_HEALTH = 100.0
@export var CURRENT_HEALTH = MAXIMUM_HEALTH
@onready var _health_bar:ProgressBar = $"../HealthBar"
@onready var _enemy:CharacterBody2D = $".."

func _ready() -> void:
	CURRENT_HEALTH = MAXIMUM_HEALTH
	_health_bar.value = CURRENT_HEALTH
	pass 


func take_damage(dmg:float)->void:
	CURRENT_HEALTH -= dmg
	_health_bar.value = CURRENT_HEALTH
	if CURRENT_HEALTH <= 0.0:
		_enemy.queue_free()

func heal(heal:float)->void:
	CURRENT_HEALTH += heal
	if CURRENT_HEALTH > 100.0:
		CURRENT_HEALTH = 100.0
	_health_bar.value = CURRENT_HEALTH
