extends Node
class_name RangedEnemyMovement


@onready var _enemy:CharacterBody2D = $".."
@onready var _world:Node2D = _enemy.get_parent()
@onready var _ranged_attack_area:Area2D = $"../AttackAreaRanged"
@onready var _ranged_stop_area:Area2D = $"../RangedStopArea"
@onready var _collision:CollisionShape2D = $"../CollisionShape2D"
@onready var _stop_raycast:RayCast2D = $"../StopRaycast"
@onready var _attack:RangedEnemyAttack = $"../Attack"

var base:StaticBody2D = null
var target = "Base"
var timer = 10.0
var stopped_raycast = false
var stopped_area = false
var stopped = false

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
	
	stopped_raycast = _stop_raycast.is_colliding()
	
	stopped = stopped_raycast or stopped_area or _attack.attacking
	
	var direction
	_enemy.velocity.y = 0.0
	if base:
		direction = _enemy.global_position.direction_to(base.global_position)
		_enemy.velocity = direction*SPEED
	if stopped:
		_enemy.velocity = Vector2(0.0,_enemy.velocity.y)
	
	_enemy.velocity.y = 0.0
	
	_enemy.move_and_slide()
	
	if direction:
		if direction.x < 0:
			_ranged_attack_area.position.x = -110.0
			_ranged_stop_area.position.x = -80.0
		elif direction.x > 0:
			_ranged_attack_area.position.x = 111.0
			_ranged_stop_area.position.x = 80.0


func _on_ranged_stop_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Base"):
			stopped_area = true


func _on_ranged_stop_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Base"):
			stopped_area = false
