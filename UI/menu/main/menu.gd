extends Control

@onready var settings_menu: SettingsMenu = $SettingsMenu

@onready var play_btn: TextureButton = $PlayBtn
@onready var exit_btn: TextureButton = $ExitBtn
@onready var settings_btn: TextureButton = $SettingsBtn

@onready var settings_exit_btn: TextureButton = $SettingsMenu.get_node("ExitBtn")

@onready var one_player_btn: TextureButton = $OnePlayerBtn
@onready var two_players_btn: TextureButton = $TwoPlayersBtn
@onready var back_btn: TextureButton = $BackBtn

@onready var animation:AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animation.play("default")
	
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	update_mouse_visibility()
	
	setup_buttons_visual()
	setup_buttons_focus()
	setup_main_menu_navigation()
	setup_player_menu_navigation()
	
	show_main_menu()
	
	if GameSession.using_controller:
		play_btn.grab_focus()


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		GameSession.using_controller = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	elif event is InputEventMouseMotion or event is InputEventMouseButton:
		GameSession.using_controller = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func update_mouse_visibility() -> void:
	if Input.get_connected_joypads().size() > 0:
		GameSession.using_controller = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		GameSession.using_controller = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	update_mouse_visibility()


func setup_buttons_visual() -> void:
	var buttons := [
		play_btn,
		settings_btn,
		exit_btn,
		one_player_btn,
		two_players_btn,
		back_btn,
		settings_exit_btn
	]
	
	for button in buttons:
		setup_button_focus_visual(button)


func setup_button_focus_visual(button: TextureButton) -> void:
	var normal_texture := button.texture_normal
	var hover_texture := button.texture_hover
	
	if hover_texture == null:
		hover_texture = normal_texture
	
	button.texture_focused = null
	
	button.focus_entered.connect(func():
		button.texture_normal = hover_texture
	)
	
	button.focus_exited.connect(func():
		button.texture_normal = normal_texture
	)
	
	button.button_down.connect(func():
		button.texture_normal = normal_texture
	)
	
	button.button_up.connect(func():
		if button.has_focus():
			button.texture_normal = hover_texture
		else:
			button.texture_normal = normal_texture
	)


func setup_buttons_focus() -> void:
	var buttons := [
		play_btn,
		settings_btn,
		exit_btn,
		one_player_btn,
		two_players_btn,
		back_btn,
		settings_exit_btn
	]
	
	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL


func setup_main_menu_navigation() -> void:
	play_btn.focus_neighbor_bottom = settings_btn.get_path()
	play_btn.focus_neighbor_top = play_btn.get_path()
	play_btn.focus_neighbor_left = play_btn.get_path()
	play_btn.focus_neighbor_right = play_btn.get_path()
	
	settings_btn.focus_neighbor_top = play_btn.get_path()
	settings_btn.focus_neighbor_bottom = exit_btn.get_path()
	settings_btn.focus_neighbor_left = settings_btn.get_path()
	settings_btn.focus_neighbor_right = settings_btn.get_path()
	
	exit_btn.focus_neighbor_top = settings_btn.get_path()
	exit_btn.focus_neighbor_bottom = exit_btn.get_path()
	exit_btn.focus_neighbor_left = exit_btn.get_path()
	exit_btn.focus_neighbor_right = exit_btn.get_path()


func setup_player_menu_navigation() -> void:
	one_player_btn.focus_neighbor_top = one_player_btn.get_path()
	one_player_btn.focus_neighbor_bottom = two_players_btn.get_path()
	one_player_btn.focus_neighbor_left = one_player_btn.get_path()
	one_player_btn.focus_neighbor_right = one_player_btn.get_path()
	
	two_players_btn.focus_neighbor_top = one_player_btn.get_path()
	two_players_btn.focus_neighbor_bottom = back_btn.get_path()
	two_players_btn.focus_neighbor_left = two_players_btn.get_path()
	two_players_btn.focus_neighbor_right = two_players_btn.get_path()
	
	back_btn.focus_neighbor_top = two_players_btn.get_path()
	back_btn.focus_neighbor_bottom = back_btn.get_path()
	back_btn.focus_neighbor_left = back_btn.get_path()
	back_btn.focus_neighbor_right = back_btn.get_path()


func show_main_menu() -> void:
	play_btn.visible = true
	settings_btn.visible = true
	exit_btn.visible = true
	
	one_player_btn.visible = false
	two_players_btn.visible = false
	back_btn.visible = false


func show_player_menu() -> void:
	play_btn.visible = false
	settings_btn.visible = false
	exit_btn.visible = false
	
	one_player_btn.visible = true
	two_players_btn.visible = true
	back_btn.visible = true


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_play_btn_pressed() -> void:
	show_player_menu()
	if GameSession.using_controller:
		one_player_btn.grab_focus()


func _on_settings_btn_pressed() -> void:
	settings_menu.visible = true
	if GameSession.using_controller:
		settings_exit_btn.grab_focus()


func _on_one_player_btn_pressed() -> void:
	GameSession.reset_players()
	GameSession.add_player(1, "keyboard", -1)
	get_tree().change_scene_to_file("res://UI/menu/select_phase/SelectPhase.tscn")


func _on_two_players_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/menu/player_input/PlayerInput.tscn")


func _on_back_btn_pressed() -> void:
	show_main_menu()
	if GameSession.using_controller:
		play_btn.grab_focus()
