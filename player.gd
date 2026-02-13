extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -400.0

var DASH_SPEED = 1200
var IS_DASHING = false

func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Mexe com o pulo
	if Input.is_action_pressed("Cima") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Cuida do dash e corrida
	if Input.is_action_just_pressed("Dash") and is_on_floor():
		IS_DASHING = true
		$Dash_timer.start()
		
	# Cuida da movimentação base do jogador
	var direction := Input.get_axis("Esquerda", "Direita")
	if direction:
		if IS_DASHING:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Cuida do dash e corrida
	if Input.is_action_pressed("Dash") and IS_DASHING == false:
		SPEED = 600
	else:
		SPEED = 300
	
	move_and_slide()


func _on_timer_timeout() -> void:
	IS_DASHING = false
