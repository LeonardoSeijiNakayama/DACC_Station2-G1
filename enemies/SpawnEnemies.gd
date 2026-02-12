extends Node

@onready var _enemy_scene = preload("res://enemies/enemy.tscn")
@onready var _collision_shape = $"../CollisionShape2D"
@onready var _spawn_area = $".."
@onready var _world = _spawn_area.get_parent()
@onready var _base = _world.get_node("Base")
@export var quantity = 5

var enemies:Array
var horde = 1
const spawn_delay = 0.7
var spawn_cd = 0.0
var can_spawn = true

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if spawn_cd > 0.0:
		spawn_cd -= delta
		return
	
	if enemies.is_empty():
		can_spawn = true
	
	if enemies.size() == quantity:
		can_spawn = false
	
	if can_spawn and _base:
		spawn_enemy()
		spawn_cd = spawn_delay
	
	


func spawn_enemy():
	var enemy:CharacterBody2D = _enemy_scene.instantiate()
	enemies.append(enemy)
		
	_world.add_child(enemy)
	enemy.global_position = get_random_point_in_area()


func get_random_point_in_area()->Vector2:
	var rect:Rect2 = _collision_shape.shape.get_rect()
	var x = randf_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randf_range(rect.position.y, rect.position.y + rect.size.y)
	
	return _spawn_area.to_global(Vector2(x, y))
	
