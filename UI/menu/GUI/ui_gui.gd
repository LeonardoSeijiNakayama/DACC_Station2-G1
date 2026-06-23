extends Node2D
class_name UiGui

@onready var progress_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar

signal base_destroyed

var baseArray: Array[Base] = []

func _ready() -> void:
	for i in get_parent().get_child_count():
		var current = get_parent().get_child(i)
	
		if current is Base:
			baseArray.append(current)


func _process(_delta: float) -> void:
	if baseArray.is_empty():
		return
	
	var total_health := 0.0
	
	for base in baseArray:
		total_health += base.get_node("Health").CURRENT_HEALTH
	
	var current_health := total_health / baseArray.size()
	
	progress_bar.value = current_health
	if current_health <= 0.0:
		base_destroyed.emit()
	
