extends CharacterBody2D
class_name Player


@onready var movement: PlayerMovement = $MovementComponent
@onready var interaction: PlayerInteraction = $InteractionComponent
@onready var highlighter: PlayerHighlighter = $HighlitgherComponent

var input_profile: Dictionary

func setup(profile: Dictionary, is_single:bool) -> void:
	input_profile = profile
	
	movement.setup_input(profile, is_single)
	interaction.setup_input(profile, is_single)

func _physics_process(delta: float) -> void:
	movement.physics_update(self, delta)

	move_and_slide()

	interaction.physics_update(self)
	highlighter.physics_update(self, interaction)


func _on_escada_body_entered(_body: Node2D) -> void:
	movement.set_on_ladder(true)


func _on_escada_body_exited(_body: Node2D) -> void:
	movement.set_on_ladder(false)
