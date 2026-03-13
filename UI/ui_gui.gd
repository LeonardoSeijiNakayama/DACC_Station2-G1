extends Node2D

@onready var progress_bar = $CanvasLayer/TextureProgressBar # Sprite da Barra de Vida

var base1 # No da base 1
var base2 # No da base 2

func _ready() -> void:
	for child in get_parent().get_child_count():
		base1 = get_parent().get_child(child)
		if base1.name == "Base1":
			break
	for child in get_parent().get_child_count():
		base2 = get_parent().get_child(child)
		if base2.name == "Base2":
			break


func _process(delta: float) -> void:
	progress_bar.value = base1.get_child(0).CURRENT_HEALTH + base2.get_child(0).CURRENT_HEALTH / 2
