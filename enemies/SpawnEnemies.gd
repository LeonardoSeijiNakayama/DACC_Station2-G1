extends Node

@onready var _enemy_scene = preload("res://enemies/enemy.tscn")
@onready var _collision_shape = $"../CollisionShape2D"
@onready var _collision_shape2 = $"../CollisionShape2D2"
@onready var _spawn_area:SpawnArea = $".."
@onready var _world = _spawn_area.get_parent()
@onready var _base = _world.get_node(_spawn_area.target)

var enemies:Array[CharacterBody2D] = []
var horde = 1
var can_spawn = true
var total_count = 0
var melee_total = 1*horde
var melee_count = 0
var ranged_total
var ranged_count = 0
var change_spawn_area = false

func _ready() -> void:
	ranged_total = _spawn_area.quantity*horde - melee_total
	pass


func _process(delta: float) -> void:
	
	if total_count == _spawn_area.quantity*horde:
		can_spawn = false
		horde += 1
		melee_count = 0
		ranged_count = 0
		melee_total = 1*horde
		ranged_total = _spawn_area.quantity*horde - melee_total
	
	if can_spawn and _base:
		spawn_enemy()
	
	if enemies.is_empty():
		can_spawn = true
		total_count = 0


func spawn_enemy():
	var enemy:CharacterBody2D = _enemy_scene.instantiate()
	var attack:EnemyAttack = enemy.get_node("Attack")
	var movement:EnemyMovement = enemy.get_node("Movement")
	
	movement.target = _spawn_area.target
	
	if melee_count<melee_total:
		melee_count+=1
		attack.type = 1
	elif melee_count==melee_total and ranged_count<ranged_total:
		ranged_count+=1
		attack.type = 2
	
	total_count += 1
	enemies.append(enemy)
		
	_world.add_child(enemy)
	
	enemy.tree_exited.connect(func():
		enemies.erase(enemy)
	)
	
	enemy.global_position = get_random_point_in_area()


func get_random_point_in_area()->Vector2:
	var shape_node:CollisionShape2D
	if change_spawn_area:
		print("um")
		shape_node = _collision_shape
		change_spawn_area = true
	else:
		print("dois")
		shape_node = _collision_shape2
		change_spawn_area = true
	
	var rect:Rect2 = shape_node.shape.get_rect()
	var x = randf_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randf_range(rect.position.y, rect.position.y + rect.size.y)
	
	return shape_node.to_global(Vector2(x, y))
	
