extends Control
class_name SettingsMenu

@onready var exit_btn: TextureButton = $ExitBtn
@onready var volume_slider: HSlider = $VolumeSlider
@onready var music_slider: HSlider = $MusicSlider


func _ready() -> void:
	setup_buttons_visual()
	setup_focus()
	setup_navigation()


func setup_buttons_visual() -> void:
	setup_button_focus_visual(exit_btn)


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
	music_slider.focus_mode = Control.FOCUS_ALL
	volume_slider.focus_mode = Control.FOCUS_ALL


func setup_navigation() -> void:
	volume_slider.focus_neighbor_top = volume_slider.get_path()
	volume_slider.focus_neighbor_bottom = music_slider.get_path()
	
	music_slider.focus_neighbor_top = volume_slider.get_path()
	music_slider.focus_neighbor_bottom = exit_btn.get_path()
	
	exit_btn.focus_neighbor_top = music_slider.get_path()
	exit_btn.focus_neighbor_bottom = exit_btn.get_path()
	
	
	exit_btn.focus_neighbor_left = exit_btn.get_path()
	exit_btn.focus_neighbor_right = exit_btn.get_path()


func _on_exit_btn_pressed() -> void:
	visible = false
	if GameSession.using_controller:
		get_parent().get_node("SettingsBtn").grab_focus()
