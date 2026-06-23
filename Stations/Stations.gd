# Esse script eh para as Estacoes que depende de 1 item e que retornam 1 item

extends Node2D

@onready var botaoSpr = $Botao_Spr # sprite do botao
@onready var label = $Produzindo_Label # Label temporaria para Mostrar Producao
@onready var timer = $Producao_Timer # Timer de Producao do Item
@onready var stationSpr = $Area_Station/Station_Spr # Sprite da Station


# Tipo de Estrutura (Altera o Sprite da Station e o item produzido e item requisitado)
@export_enum("Crafting", "Fornalha") var type: int


var can_use = false # Verifica se atende os requisitos para iniciar producao
var player_ref: Node # No do player
var ore_ref: Node # No do item que requisita para producao
var prod # Item que sera produzido
var station # Imagem da Station
var area_type # Area do item requisitado

# Quando entra na cena ele verifica o tipo e associa os itens e sprites adequados
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
	
# Verifica se pode iniciar a producao
func _process(_delta: float) -> void:
	if can_use and Input.is_action_just_pressed("ui_accept"): # Se apertar a tecla [Enter]
		ore_ref.queue_free() # deleta o no do item segurado pelo player
		player_ref.holding = false # coloca o player em estado de "nao segurando"
		label.visible = true # torna visivel a label de producao
		botaoSpr.visible = false # torna invisivel o sprite do botao
		timer.start() # inicia o timer de producao
		can_use = false # impede de usar a station


# Quando o player entra na area de atuacao, segurando o item correto e 
# o timer de producao nao esta ativado
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.holding and body.item_hold_id.get_child(2).name == area_type and timer.is_stopped():
		botaoSpr.visible = true 
		player_ref = body # associa a variavel ao no do player
		ore_ref = body.item_hold_id # associa a variavel ao item segurado
		can_use = true # permite o uso da estacao

# Se o player sair da area de atuacao ele impede o uso
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		botaoSpr.visible = false
		can_use = false

# Quando o timer de producao termina
func _on_producao_timer_timeout() -> void:
	label.visible = false
	var prod_ferro = prod.instantiate() # Instancia o item produzido
	prod_ferro.position = Vector2(position.x, position.y - 20) # Define as cordenadas de spawn
	get_parent().add_child(prod_ferro) # Adiciona como filho do No Principal
