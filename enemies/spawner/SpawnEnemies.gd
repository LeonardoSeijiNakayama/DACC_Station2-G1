extends Node
class_name EnemySpawner

signal wave_started(wave_number: int)
signal wave_finished(wave_number: int, spawner: EnemySpawner)
signal enemy_spawned(enemy: CharacterBody2D)

@export var melee_enemy_scene: PackedScene = preload("res://enemies/melee/MeleeEnemy.tscn")
@export var ranged_enemy_scene: PackedScene = preload("res://enemies/ranged/RangedEnemy.tscn")

@onready var _collision_shape_front: CollisionShape2D = $"../CollisionShape2D"
@onready var _collision_shape_back: CollisionShape2D = $"../CollisionShape2D2"

@onready var _spawn_area: SpawnArea = $".."
@onready var _world: Node = _spawn_area.get_parent().get_parent()
@onready var _base: Node = _world.get_node_or_null(_spawn_area.target)

var active_enemies: Array[CharacterBody2D] = []

var shutting_down := false

var current_wave: WaveConfig = null
var current_wave_index := 0

var remaining_melee := 0
var remaining_ranged := 0

var wave_running := false
var use_front_area_next := false

var spawn_timer: Timer


func _ready() -> void:
	randomize()
	
	add_to_group("enemy_spawners")
	
	create_timers()
	
	if _spawn_area.waves.is_empty():
		create_default_wave()


func create_timers() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func create_default_wave() -> void:
	var default_wave := WaveConfig.new()
	default_wave.melee_quantity = 1
	default_wave.ranged_quantity = 3
	default_wave.spawn_interval = 0.7
	default_wave.delay_after_wave = 3.0
	default_wave.max_alive = 6

	_spawn_area.waves.append(default_wave)


func has_wave(wave_index: int) -> bool:
	return wave_index >= 0 and wave_index < _spawn_area.waves.size()


func get_last_wave_index() -> int:
	return max(_spawn_area.waves.size() - 1, 0)


func start_wave(wave_index: int) -> void:
	if shutting_down or not is_inside_tree():
		return
	
	clear_invalid_enemies()
	
	current_wave_index = wave_index
	
	if not has_wave(wave_index):
		wave_running = false
		wave_finished.emit(wave_index + 1, self)
		return
	
	current_wave = _spawn_area.waves[wave_index]
	
	remaining_melee = current_wave.melee_quantity
	remaining_ranged = current_wave.ranged_quantity
	
	wave_running = true
	
	
	wave_started.emit(wave_index + 1)
	
	spawn_timer.start(0.2)


func _on_spawn_timer_timeout() -> void:
	if shutting_down or not is_inside_tree():
		return
	
	if not wave_running:
		return
	
	clear_invalid_enemies()

	if _base == null or not is_instance_valid(_base):
		return
	
	if is_wave_complete():
		finish_wave()
		return
	
	if can_spawn_enemy():
		spawn_enemy()
	
	if wave_running:
		spawn_timer.start(current_wave.spawn_interval)


func can_spawn_enemy() -> bool:
	if current_wave == null:
		return false
	
	if remaining_melee + remaining_ranged <= 0:
		return false
	
	if active_enemies.size() >= current_wave.max_alive:
		return false
	
	return true


func is_wave_complete() -> bool:
	var no_enemies_to_spawn := remaining_melee + remaining_ranged <= 0
	var no_enemies_alive := active_enemies.is_empty()
	
	return no_enemies_to_spawn and no_enemies_alive


func finish_wave() -> void:
	if shutting_down or not is_inside_tree():
		return
	
	if not wave_running:
		return
	
	wave_running = false
	
	
	wave_finished.emit(current_wave_index + 1, self)


func spawn_enemy() -> void:
	var enemy_scene := get_next_enemy_scene()
	
	if enemy_scene == null:
		return

	var enemy: CharacterBody2D = enemy_scene.instantiate()
	
	setup_enemy(enemy)
	
	active_enemies.append(enemy)
	_world.add_child(enemy)
	
	enemy.global_position = get_random_point_in_area()
	
	enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))
	
	enemy_spawned.emit(enemy)


func get_next_enemy_scene() -> PackedScene:
	if remaining_melee <= 0 and remaining_ranged <= 0:
		return null
	
	if remaining_melee <= 0:
		remaining_ranged -= 1
		return ranged_enemy_scene
	
	if remaining_ranged <= 0:
		remaining_melee -= 1
		return melee_enemy_scene
	
	if current_wave.random_order:
		var total_remaining := remaining_melee + remaining_ranged
		var melee_chance := float(remaining_melee) / float(total_remaining)
	
		if randf() < melee_chance:
			remaining_melee -= 1
			return melee_enemy_scene
		else:
			remaining_ranged -= 1
			return ranged_enemy_scene
	
	# Ordem alternada simples
	if remaining_melee >= remaining_ranged:
		remaining_melee -= 1
		return melee_enemy_scene
	else:
		remaining_ranged -= 1
		return ranged_enemy_scene


func setup_enemy(enemy: CharacterBody2D) -> void:
	var movement := enemy.get_node_or_null("Movement")
	
	if movement != null:
		movement.set("target", _spawn_area.target)
	
	var sprite := enemy.get_node_or_null("AnimatedSprite2D")
	
	if sprite != null and use_front_area_next:
		sprite.z_index += 1


func get_random_point_in_area() -> Vector2:
	var shape_node: CollisionShape2D
	
	if use_front_area_next:
		shape_node = _collision_shape_front
	else:
		shape_node = _collision_shape_back
	
	use_front_area_next = not use_front_area_next
	
	var rect: Rect2 = shape_node.shape.get_rect()
	
	var x := randf_range(rect.position.x, rect.position.x + rect.size.x)
	var y := randf_range(rect.position.y, rect.position.y + rect.size.y)
	
	return shape_node.to_global(Vector2(x, y))


func _on_enemy_tree_exited(enemy: CharacterBody2D) -> void:
	active_enemies.erase(enemy)
	
	if shutting_down or not is_inside_tree():
		return
	
	if wave_running and is_wave_complete():
		finish_wave()


func clear_invalid_enemies() -> void:
	for i in range(active_enemies.size() - 1, -1, -1):
		if not is_instance_valid(active_enemies[i]):
			active_enemies.remove_at(i)


func _exit_tree() -> void:
	shutting_down = true
	wave_running = false
	
	if spawn_timer != null:
		spawn_timer.stop()
