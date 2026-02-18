# Esse script serve para toda station que gere um item (Carvao ou Ferro)

extends Node2D

@onready var sprMina = $Area2D.get_child(1)
@onready var sprBotao = $Botao_Spr
@onready var area = $Area2D
@onready var timer = $Producao_Timer
@onready var label = $Produzindo_Label

@export_enum("Carvao", "Ferro") var type: int

var in_range = false
var ore
var station
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == 0:
		ore = load("res://Stations/Carvao_Minerio.tscn")
		station = load("res://Stations/placeholders/mina_carvao_ph.png")
	else:
		ore = load("res://Stations/Ferro_Minerio.tscn")
		station = load("res://Stations/placeholders/mina_ferro_ph.png")

	sprMina.texture = station

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
	var new_ore = ore.instantiate()
	new_ore.position = Vector2(position.x, position.y - 20)
	new_ore.rotation = [-3, -2 -1, 0, 1, 2, 3].pick_random()
	get_parent().add_child(new_ore)
	label.visible = false
	print("Pronto!")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		in_range = true
		sprBotao.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		sprBotao.visible = false
		label.visible = false
		in_range = false
		if !timer.is_stopped():
			timer.stop()
