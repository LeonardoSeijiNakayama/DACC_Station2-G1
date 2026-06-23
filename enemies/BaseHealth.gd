extends Node
class_name BaseHealth

@export var MAXIMUM_HEALTH = 100.0
@export var CURRENT_HEALTH = MAXIMUM_HEALTH

func _ready() -> void:
	CURRENT_HEALTH = MAXIMUM_HEALTH
	pass 


func take_damage(dmg:float)->void:
	CURRENT_HEALTH -= dmg
	if CURRENT_HEALTH <= 0.0:
		pass

func heal(quantity:float)->void:
	CURRENT_HEALTH += quantity
	if CURRENT_HEALTH > 100.0:
		CURRENT_HEALTH = 100.0
