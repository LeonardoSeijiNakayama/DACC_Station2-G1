extends Node
class_name PlayerState

@onready var player:CharacterBody2D = $".."

const IDLE = 0
const WALKING = 1
const JUMPING = 2

var current_state = 0
var holding = false

func _physics_process(_delta: float) -> void:
	if abs(player.velocity.x) <= 1.0 and player.is_on_floor():
		current_state = IDLE
	
	if abs(player.velocity.x) >= 1.0 and player.is_on_floor():
		current_state = WALKING
	
