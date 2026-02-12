extends Node
class_name EnemyMovement

@onready var _enemy:CharacterBody2D = $".."
@onready var _world:Node2D = _enemy.get_parent()
@onready var _attack_area:Area2D = $"../AttackArea"

var base:StaticBody2D = null

const GRAVITY = -50.0
const SPEED = 70.0

func _ready() -> void:
	base = _world.get_node("Base")
	pass


func _process(delta: float) -> void:
	var direction
	if not _enemy.is_on_floor():
		_enemy.velocity.y -= GRAVITY*delta
	else:
		_enemy.velocity.y = 0.0
		if base:
			direction = _enemy.global_position.direction_to(base.global_position)
			_enemy.velocity = direction*SPEED
	
	_enemy.move_and_slide()
	
	if direction:
		if direction.x < 0:
			_attack_area.position.x = -31.0
		elif direction.x > 0:
			_attack_area.position.x = 0.0
