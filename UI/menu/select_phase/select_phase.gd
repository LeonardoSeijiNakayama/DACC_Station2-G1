extends Control

@onready var train:AnimatedSprite2D = $AnimatedSprite2D

var current_phase = 0

func _ready() -> void:
	train.play("Working")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left") and train.position.x > 66.0:
		train.position.x -= 64.0
		current_phase -=1
	elif Input.is_action_just_pressed("ui_left") and train.position.x <=66.0:
		get_tree().change_scene_to_file("res://UI/menu/main/menu.tscn")
	if Input.is_action_just_pressed("ui_right") and train.position.x<258.0:
		train.position.x += 64.0
		current_phase+=1
	if Input.is_action_just_pressed("ui_accept"):
		match current_phase:
			0:
				get_tree().change_scene_to_file("res://phases/Phase1.tscn")
			1:
				pass
			2:
				pass
			3:
				pass
