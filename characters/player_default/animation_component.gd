extends Node

@onready var state:PlayerState = $"../StateComponent"
@onready var animation:AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var interaction:PlayerInteraction = $"../InteractionComponent"
@onready var player:CharacterBody2D = $".."

func _process(_delta: float) -> void:
	
	if player.velocity.x < 0.0:
		animation.flip_h = true
	elif player.velocity.x > 0.0:
		animation.flip_h = false
	
	match state.current_state:
		PlayerState.IDLE:
			if interaction.holding:
				play_animation("HoldingIdle")
			else:
				play_animation("Idle")
		PlayerState.WALKING:
			if interaction.holding:
				play_animation("HoldingWalking")
			else:
				play_animation("Walking")


func play_animation(anim_name: String) -> void:
	if animation.animation != anim_name:
		animation.play(anim_name)
