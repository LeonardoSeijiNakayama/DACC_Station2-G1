extends Node
class_name RangedEnemyMovement


@onready var _enemy:CharacterBody2D = $".."
@onready var _world:Node2D = _enemy.get_parent()
@onready var _ranged_attack_area:Area2D = $"../AttackAreaRanged"
@onready var _stop_area:Area2D = $"../RangedStopArea"
@onready var _sprite:AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var _collision:CollisionShape2D = $"../CollisionShape2D"
@onready var _stop_raycast:RayCast2D = $"../StopRaycast"

var base:StaticBody2D = null
var target = "Base"
var stopped_raycast = false
var stopped_area = false
var stopped = false

var auxiliarSprite:AnimatedSprite2D = null
var auxiliarSprite2:AnimatedSprite2D = null

const SPEED = 10.0

func _ready() -> void:
	base = _world.get_node(target)
	_collision.disabled = true
	auxiliarSprite = get_parent().get_node_or_null("AuxiliarSprite")
	auxiliarSprite2 = get_parent().get_node_or_null("AuxiliarSprite2")
	pass


func _process(_delta: float) -> void:
	
	stopped_raycast = _stop_raycast.is_colliding()
	
	stopped = stopped_raycast or stopped_area
	
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
			_ranged_attack_area.position.x = -40.0
			_stop_area.position.x = -40.0
			_sprite.flip_h = true
			_stop_raycast.rotation_degrees = -180
			if auxiliarSprite != null:
				auxiliarSprite.flip_h = true
				auxiliarSprite.offset.x = -14.0
			if auxiliarSprite2 != null:
				auxiliarSprite2.flip_h = true
				auxiliarSprite2.offset.x = 20.0
		elif direction.x > 0:
			_ranged_attack_area.position.x = 40.0
			_stop_area.position.x = 40.0


func _on_ranged_stop_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Base"):
			stopped_area = true


func _on_ranged_stop_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Base"):
			stopped_area = false
