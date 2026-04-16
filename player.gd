extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -400.0
var DASH_SPEED = 1200

var IS_DASHING = false
var esta_na_escada = false
var escalando = false


# VARIAVEIS DE SEGURAR ITENS #
@onready var area = $Area_Player # Area para detectar itens coletaveis
var can_hold = false # Verificar se pode ou nao pegar itens
@export var holding = false # Verificar se esta ou nao segurando um item
@export var item_hold_id: Node # No do item que esta segurando 
# Lista de Itens que pode segurar (Nome se refere as Areas de atuacao desses itens)
const itens_grupo = ["Area_Carvao", "Area_Ferro", "Area_Bola", "Area_Ferro_Prod"]


func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Cuida do estado de dash
	if Input.is_action_just_pressed("Dash") and is_on_floor():
		IS_DASHING = true
		$Dash_timer.start()


	# Mexe com o pulo
	if Input.is_action_pressed("Pulo") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Lida com as escadas
	if esta_na_escada and Input.is_action_just_pressed("Cima"):
		escalando = true
	if Input.is_action_just_pressed("Pulo") or esta_na_escada == false:
		escalando = false
	
	if escalando == true:
		var direction_escada := Input.get_axis("Cima", "Baixo")
		if direction_escada:
			if IS_DASHING:
				velocity.y = direction_escada * DASH_SPEED
			else:
				velocity.y = direction_escada * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)


	# Cuida da movimentação base do jogador e dash
	var direction := Input.get_axis("Esquerda", "Direita")
	if direction and escalando == false:
		if IS_DASHING:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Cuida da corrida
	if Input.is_action_pressed("Dash") and IS_DASHING == false:
		SPEED = 600
	else:
		SPEED = 300
	
	move_and_slide()

	# MECANIMA DE SEGURAR ITENS
	match holding: # State Machine que varia entre Segurando ou Nao Segurando
		true: # Se estiver segurando
			# a posicao do item ficara relacionada a posicao do player
			item_hold_id.position = Vector2(position.x, position.y - 30)
			if Input.is_action_just_pressed("ui_accept"): # Se apertar a tecla [Enter]
				item_hold_id.freeze = false # Item descongela
				item_hold_id = null # esquece o no do item
				holding = false # muda de estado para "Nao segurando"
				
		false: # Se Nao estiver segurando
			# Verifica se tem Area2D na area de atuacao
			if area.has_overlapping_areas():
				for item in area.get_overlapping_areas():
					# Se tiver e um deles for um item coletavel
					if item.name in itens_grupo: 
						can_hold = true # Permite que segure um item
						item_hold_id = item.get_parent() # pega o no de um dos itens
			else: # Se nao tiver itens na area de atuacao, impede que segure um item
				can_hold = false
						
			if can_hold: # Se ele pode segurar um item
				if Input.is_action_just_pressed("ui_accept"): # se apertar a tecla [Enter]
					item_hold_id.rotation = 0 # define a rotacao do item para 0
					item_hold_id.freeze = true # congela o item
					can_hold = false # Impede de pegar outro item
					holding = true # muda para estado de "Segurando"

func _on_timer_timeout() -> void:
	IS_DASHING = false


func _on_escada_body_entered(body: Node2D) -> void:
	esta_na_escada = true 


func _on_escada_body_exited(body: Node2D) -> void:
	esta_na_escada = false
