extends Node
class_name EnemyMovement


@onready var _enemy:CharacterBody2D = $".."
@onready var _world:Node2D = _enemy.get_parent()
@onready var _sprite:AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var _melee_attack_area:Area2D = $"../AttackAreaMelee"
@onready var _collision:CollisionShape2D = $"../CollisionShape2D"
@onready var _stop_raycast:RayCast2D = $"../StopRaycast"

var wing_animation:AnimatedSprite2D = null
var base:StaticBody2D = null
var target = "Base"
var stopped_raycast = false
var stopped_area = false
var stopped = false

const SPEED = 15.0

func _ready() -> void:
	base = _world.get_node(target)
	_collision.disabled = true
	wing_animation = get_parent().get_node_or_null("AuxiliarSprite")
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
			_melee_attack_area.position.x = -18.0
			_sprite.flip_h = true
			_sprite.offset.x = -1.7
			if wing_animation:
				wing_animation.flip_h = true
				wing_animation.offset.x = 5.3
			_stop_raycast.rotation_degrees = 180.0
		elif direction.x > 0:
			_melee_attack_area.position.x = 18.0
