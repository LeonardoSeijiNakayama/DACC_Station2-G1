extends Node2D

@export var train_scene: PackedScene = preload("res://Tileset/MariaFumaca/maria-fumaca.tscn")
@export var spawn_position: Vector2 = Vector2(722, 166)

@onready var timer: Timer = $TrainTimer

func _ready() -> void:
	timer.timeout.connect(spawn_train)
	timer.start()

func spawn_train() -> void:
	var train:Train = train_scene.instantiate()
	train.z_index = 1
	train.position = spawn_position
	get_parent().add_child(train)
