extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -400.0
var DASH_SPEED = 1200

var IS_DASHING = false
var esta_na_escada = false
var escalando = false

var can_hold = false
var holding = false
var item_hold_id = ""

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

	# Segurar Itens	
	match holding:
		true:
			item_hold_id.position.x = position.x
			item_hold_id.position.y = position.y - 30
			if Input.is_action_just_pressed("ui_accept"):
				item_hold_id.freeze = false
				holding = false
		false:
			if can_hold:
				if Input.is_action_just_pressed("ui_accept"):
					item_hold_id.rotation = 0
					item_hold_id.freeze = true
					holding = true
	

func _on_timer_timeout() -> void:
	IS_DASHING = false


func _on_escada_body_entered(body: Node2D) -> void:
	esta_na_escada = true 


func _on_escada_body_exited(body: Node2D) -> void:
	esta_na_escada = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Area_Carvao" or area.name == "Area_Ferro" and !holding:
			can_hold = true
			item_hold_id = area.get_parent()

func _on_area_player_area_exited(area: Area2D) -> void:
	if area.name == "Area_Carvao" or area.name == "Area_Ferro" and !holding:
		can_hold = false
