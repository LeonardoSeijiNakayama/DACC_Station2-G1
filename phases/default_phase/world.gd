extends Node2D
class_name World

@export var train_scene: PackedScene = preload("res://Tileset/MariaFumaca/maria-fumaca.tscn")
@export var spawn_position: Vector2 = Vector2(722, 166)
@export var train_destroy_x: float = -300.0

var spawn_points: Array[Vector2] = []

@onready var timer: Timer = $"../TrainTimer"
@onready var character1: PackedScene = preload("res://characters/ironsmith/ironsmith_character.tscn")
@onready var character2: PackedScene = preload("res://characters/buff/buff_character.tscn")
@onready var playerSpawners:Node2D = $PlayerSpawners

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

	timer.timeout.connect(spawn_train)
	timer.start()

	load_spawn_points()
	setup_ui_signals()

	if GameSession.players.is_empty():
		GameSession.reset_players()
		GameSession.add_player(1, "keyboard", -1)

	spawn_players()


func load_spawn_points() -> void:
	spawn_points.clear()

	for child in playerSpawners.get_children():
		if child is SpawnPoint:
			spawn_points.append(child.global_position)


func setup_ui_signals() -> void:
	for child in get_children():
		if child is UiGui:
			child.base_destroyed.connect(_on_base_destroyed)


func spawn_train() -> void:
	var train: Train = train_scene.instantiate()
	train.z_index = -2
	train.position = spawn_position
	train.destroy_x = train_destroy_x
	get_parent().add_child(train)


func spawn_players() -> void:
	var is_single := GameSession.players.size() == 1

	for i in GameSession.players.size():
		if i >= spawn_points.size():
			push_warning("Não existe SpawnPoint suficiente para o jogador " + str(i + 1))
			return

		var profile: Dictionary = GameSession.players[i]
		var character: Character = null

		if profile["id"] == 1:
			character = character1.instantiate()
		elif profile["id"] == 2:
			character = character2.instantiate()

		if character == null:
			push_warning("Personagem não encontrado para o jogador " + str(profile["id"]))
			continue

		add_child(character)

		var player: Player = character.get_node("player")
		player.global_position = spawn_points[i]
		player.setup(profile, is_single)


func _on_base_destroyed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/menu/main/menu.tscn")
