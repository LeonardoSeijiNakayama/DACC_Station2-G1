# Esse script serve para toda station que gere um item 
# que precise apenas do Player (Carvao ou Ferro)

extends Node2D

@onready var sprMina = $Area_Mina.get_child(1) # sprite da Station
@onready var sprBotao = $Botao_Spr # sprite do Botao 
@onready var area = $Area_Mina # Area de atuacao da Station
@onready var timer = $Producao_Timer # Timer para delay de geracao do item
@onready var label = $Produzindo_Label # Label Temporaria para Mostrar Producao


# Tipo de Estrutura (Altera o Sprite da Station e o item produzido)
@export_enum("Carvao", "Ferro") var type: int


var in_range = false # Se o player esta dentro da area de atuacao
var ore # recebe a cena do item que sera produzido
var station # recebe o sprite da station associada


# Quando entra na cena ele verifica o tipo e associa os itens e sprites adequados
func _ready() -> void:
	if type == 0:
		ore = load("res://Stations/Carvao_Minerio.tscn")
		station = load("res://Stations/placeholders/mina_carvao_ph.png")
	else:
		ore = load("res://Stations/Ferro_Minerio.tscn")
		station = load("res://Stations/placeholders/mina_ferro_ph.png")

	sprMina.texture = station

# Interacao do Player
func _process(delta: float) -> void:
	if in_range: # Se estiver dentro da area de atuacao e segurar[Enter]
		if Input.is_action_pressed("ui_accept"): 
			if timer.is_stopped(): # se o time estiver parado ele comeca
				sprBotao.visible = false
				label.visible = true
				timer.start()
		elif Input.is_action_just_released("ui_accept"): # quando ele soltar a tecla
			if !timer.is_stopped(): # se o timer estiver ocorrendo ele interrompe
				label.visible = false
				sprBotao.visible = true
				timer.stop()
				
# Quando o tempo de producao terminar, spawna o item produzido
func _on_producao_timer_timeout() -> void:
	var new_ore = ore.instantiate() # Instancia o item na cena
	new_ore.position = Vector2(position.x, position.y - 20) # Define a posicao dele na cena
	new_ore.rotation = [-3, -2 -1, 0, 1, 2, 3].pick_random() # Escolha uma rotacao aleatoria
	get_parent().add_child(new_ore) # adiciona ele como filho do no principal
	label.visible = false


# Quando o player entra na area de atuacao
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		in_range = true 
		sprBotao.visible = true # deixa visible o sprite do botao


# Quando o player sai da area de atuacao
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		sprBotao.visible = false # torna invisivel o sprite do botao
		label.visible = false # torna invisivel a label de producao
		in_range = false 
		if !timer.is_stopped(): # interrompe a producao se ela estiver ocorrendo
			timer.stop()
