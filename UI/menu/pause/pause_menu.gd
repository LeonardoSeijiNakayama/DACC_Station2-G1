extends Control
class_name PauseMenu

@onready var settings_menu: SettingsMenu = $SettingsMenu

@onready var exit_btn: TextureButton = $ExitBtn
@onready var settings_btn: TextureButton = $SettingsBtn
@onready var restart_btn: TextureButton = $RestartBtn
@onready var resume_btn: TextureButton = $ResumeBtn

@onready var settings_exit_btn: TextureButton = $SettingsMenu.get_node("ExitBtn")


func _ready() -> void:
	setup_buttons_visual()
	setup_focus()
	setup_navigation()


func setup_buttons_visual() -> void:
	var buttons := [
		resume_btn,
		restart_btn,
		settings_btn,
		exit_btn,
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


func setup_focus() -> void:
	exit_btn.focus_mode = Control.FOCUS_ALL
	settings_btn.focus_mode = Control.FOCUS_ALL
	restart_btn.focus_mode = Control.FOCUS_ALL
	resume_btn.focus_mode = Control.FOCUS_ALL


func setup_navigation() -> void:
	# Resume
	resume_btn.focus_neighbor_left = resume_btn.get_path()
	resume_btn.focus_neighbor_right = restart_btn.get_path()
	resume_btn.focus_neighbor_top = resume_btn.get_path()
	resume_btn.focus_neighbor_bottom = resume_btn.get_path()
	
	# Restart
	restart_btn.focus_neighbor_left = resume_btn.get_path()
	restart_btn.focus_neighbor_right = settings_btn.get_path()
	restart_btn.focus_neighbor_top = restart_btn.get_path()
	restart_btn.focus_neighbor_bottom = restart_btn.get_path()
	
	# Settings
	settings_btn.focus_neighbor_left = restart_btn.get_path()
	settings_btn.focus_neighbor_right = exit_btn.get_path()
	settings_btn.focus_neighbor_top = settings_btn.get_path()
	settings_btn.focus_neighbor_bottom = settings_btn.get_path()
	
	# Exit
	exit_btn.focus_neighbor_left = settings_btn.get_path()
	exit_btn.focus_neighbor_right = exit_btn.get_path()
	exit_btn.focus_neighbor_top = exit_btn.get_path()
	exit_btn.focus_neighbor_bottom = exit_btn.get_path()


func open_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	if GameSession.using_controller:
		resume_btn.grab_focus()


func close_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_exit_btn_pressed() -> void:
	close_pause_menu()
	get_tree().change_scene_to_file("res://UI/menu/select_phase/SelectPhase.tscn")


func _on_settings_btn_pressed() -> void:
	settings_menu.visible = true
	if GameSession.using_controller:
		settings_exit_btn.grab_focus()


func _on_restart_btn_pressed() -> void:
	close_pause_menu()
	get_tree().reload_current_scene()


func _on_resume_btn_pressed() -> void:
	close_pause_menu()
