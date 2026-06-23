extends Node2D
class_name Main

@onready var world: World = $World
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var resume_btn:TextureButton = $PauseMenu.get_node("ResumeBtn")
@onready var settings_menu:SettingsMenu = $PauseMenu.get_node("SettingsMenu")
@onready var train_timer: Timer = $TrainTimer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	train_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	pause_menu.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause") and !settings_menu.visible:
		toggle_pause()
	elif Input.is_action_just_pressed("Pause") and settings_menu.visible:
		settings_menu.visible = false


func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused
	resume_btn.grab_focus()
