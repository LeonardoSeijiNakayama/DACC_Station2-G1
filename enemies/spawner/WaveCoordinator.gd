extends Node
class_name WaveCoordinator

@export var start_delay := 0.5
@export var delay_between_waves := 3.0
@export var repeat_last_wave := false

var spawners: Array[EnemySpawner] = []
var finished_spawners: Array[EnemySpawner] = []

var current_wave_index := 0
var waves_running := false

var next_wave_timer: Timer


func _ready() -> void:
	create_timer()
	
	await get_tree().process_frame
	
	find_spawners()
	start_wave_after_delay(start_delay)


func create_timer() -> void:
	next_wave_timer = Timer.new()
	next_wave_timer.one_shot = true
	add_child(next_wave_timer)
	next_wave_timer.timeout.connect(start_current_wave)


func find_spawners() -> void:
	spawners.clear()
	
	for node in get_tree().get_nodes_in_group("enemy_spawners"):
		if node is EnemySpawner:
			spawners.append(node)
	
			if not node.wave_finished.is_connected(_on_spawner_wave_finished):
				node.wave_finished.connect(_on_spawner_wave_finished)
	


func start_wave_after_delay(delay: float) -> void:
	next_wave_timer.start(delay)


func start_current_wave() -> void:
	if spawners.is_empty():
		return
	
	if not has_any_spawner_with_wave(current_wave_index):
		if repeat_last_wave:
			current_wave_index = get_last_available_wave_index()
		else:
			waves_running = false
			return
	
	finished_spawners.clear()
	waves_running = true
	
	
	for spawner in spawners:
		spawner.start_wave(current_wave_index)


func _on_spawner_wave_finished(wave_number: int, spawner: EnemySpawner) -> void:
	if spawner in finished_spawners:
		return
	
	finished_spawners.append(spawner)
	
	
	if finished_spawners.size() >= spawners.size():
		finish_global_wave()


func finish_global_wave() -> void:
	
	waves_running = false
	current_wave_index += 1
	
	start_wave_after_delay(delay_between_waves)


func has_any_spawner_with_wave(wave_index: int) -> bool:
	for spawner in spawners:
		if spawner.has_wave(wave_index):
			return true
	
	return false


func get_last_available_wave_index() -> int:
	var last_index := 0
	
	for spawner in spawners:
		last_index = max(last_index, spawner.get_last_wave_index())
	
	return last_index
