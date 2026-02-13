extends Node
class_name EnemyMovement


@onready var _enemy:CharacterBody2D = $".."
@onready var _world:Node2D = _enemy.get_parent()
@onready var _melee_attack_area:Area2D = $"../AttackAreaMelee"
@onready var _ranged_attack_area:Area2D = $"../AttackAreaRanged"
@onready var _attack:EnemyAttack = $"../Attack"
@onready var _collision:CollisionShape2D = $"../CollisionShape2D"

var base:StaticBody2D = null
var target = "Base"
var timer = 6.0

const SPEED = 70.0

func _ready() -> void:
	base = _world.get_node(target)
	_collision.disabled = true
	pass


func _process(delta: float) -> void:
	
	if timer>=0.0:
		timer-=delta
	if timer<=0.0:
		_enemy.queue_free()
	
	var direction
	_enemy.velocity.y = 0.0
	if base and not _attack.base_in_range:
		direction = _enemy.global_position.direction_to(base.global_position)
		_enemy.velocity = direction*SPEED
	if _attack.base_in_range:
		_enemy.velocity = Vector2(0.0,_enemy.velocity.y)
	
	_enemy.velocity.y = 0.0
	
	_enemy.move_and_slide()
	
	if direction:
		if direction.x < 0:
			_melee_attack_area.position.x = -31.0
			_ranged_attack_area.position.x = -200.0
		elif direction.x > 0:
			_melee_attack_area.position.x = 0.0
