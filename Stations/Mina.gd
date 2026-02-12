# Esse script serve para toda station que gere um item (Carvao ou Ferro)

extends Node2D

@onready var sprMina = $Mina_Spr
@onready var sprBotao = $Botao_Spr
@onready var area = $Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	sprBotao.visible = true


func _on_area_2d_mouse_exited() -> void:
	sprBotao.visible = false
