extends Control

func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Tileset/tileset-test.tscn")
