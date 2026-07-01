extends Control

@onready var p1_input_options:TextureRect = $P1InputOptions
@onready var p2_input_options:TextureRect = $P2InputOptions
@onready var p1_checked:TextureRect = $P1Checked
@onready var p2_checked:TextureRect = $P2Checked
@onready var next_scene_timer:Timer = $NextSceneTimer

var id = 0

func _ready() -> void:
	GameSession.reset_players()


func _input(event: InputEvent) -> void:
	if GameSession.players.size() >= 2:
		return

	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_SPACE:
			_try_add_player({
				"type": "keyboard",
				"device": -1
			})
		elif event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			return_to_main_menu()

	if event is InputEventJoypadButton:
		if event.pressed and event.button_index == JOY_BUTTON_A:
			_try_add_player({
				"type": "joypad",
				"device": event.device
			})
		elif event.pressed and event.button_index == JOY_BUTTON_B:
			return_to_main_menu()


func _try_add_player(profile: Dictionary) -> void:
	for player in GameSession.players:
		if player.type == profile.type and player.device == profile.device:
			return

	if profile.type == "keyboard":
		for player in GameSession.players:
			if player.type == "keyboard":
				print("return1")
				return

	id+=1

	GameSession.add_player(id, profile.type, profile.device)

	if GameSession.players.size() == 1:
		p1_input_options.visible = false
		p1_checked.visible = true

	if GameSession.players.size() == 2:
		p2_input_options.visible = false
		p2_checked.visible = true
		next_scene_timer.start()


func return_to_main_menu():
	GameSession.reset_players()
	get_tree().change_scene_to_file("res://UI/menu/main/menu.tscn")


func _on_next_scene_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://UI/menu/select_phase/SelectPhase.tscn")
