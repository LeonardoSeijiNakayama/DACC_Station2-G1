extends Node2D

@onready var botaoSpr = $Botao_Spr
@onready var label = $Produzindo_Label
@onready var timer = $Producao_Timer
@onready var stationSpr = $Area_Fornalha/Fornalha_Spr
@export_enum("Crafting", "Fornalha") var type: int

var can_use = false
var player_ref: Node
var ore_ref: Node
var prod
var station
var area_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == 0:
		prod = load("res://Stations/Bola.tscn")
		station = load("res://Stations/placeholders/crafting_ph.png")		
		area_type = "Area_Ferro_Prod"
	else:
		prod = load("res://Stations/Ferro_Produzido.tscn")
		station = load("res://Stations/placeholders/fornalaha_ph.png")		
		area_type = "Area_Ferro"
	
	stationSpr.texture = station
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_use and Input.is_action_just_pressed("ui_accept"):
		ore_ref.queue_free()
		player_ref.holding = false
		label.visible = true
		botaoSpr.visible = false
		timer.start()
		can_use = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.holding and body.item_hold_id.get_child(2).name == area_type and timer.is_stopped():
		botaoSpr.visible = true
		player_ref = body
		ore_ref = body.item_hold_id
		can_use = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		botaoSpr.visible = false
		can_use = false


func _on_producao_timer_timeout() -> void:
	label.visible = false
	var prod_ferro = prod.instantiate()
	prod_ferro.position = Vector2(position.x, position.y - 20)
	get_parent().add_child(prod_ferro)
	print("pronto")
