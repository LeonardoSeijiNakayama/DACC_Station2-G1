# Esse script serve para toda station que gere um item (Carvao ou Ferro)

extends Node2D

@onready var sprMina = $Mina_Spr
@onready var sprBotao = $Botao_Spr
@onready var area = $Area2D
@onready var timer = $Producao_Timer
@onready var label = $Produzindo_Label
var carvao = load("res://Stations/Carvao_Minerio.tscn")

var in_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_range:
		if Input.is_action_pressed("ui_accept"):
			if timer.is_stopped():
				sprBotao.visible = false
				label.visible = true
				timer.start()
		elif Input.is_action_just_released("ui_accept"):
			if !timer.is_stopped():
				label.visible = false
				sprBotao.visible = true
				timer.stop()
# Quando mouse entra na area da mina, aparece um botao que ele precisa apertar
func _on_area_2d_mouse_entered() -> void:
	in_range = true
	sprBotao.visible = true

# Quando mouse sai na area da mina, o botao some
func _on_area_2d_mouse_exited() -> void:
	sprBotao.visible = false
	label.visible = false
	in_range = false
	if !timer.is_stopped():
		timer.stop()

func _on_producao_timer_timeout() -> void:
	add_child(carvao.instantiate())
	label.visible = false
	print("Pronto!")
