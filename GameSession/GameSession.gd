extends Node

var players: Array[Dictionary] = []

func reset_players() -> void:
	players.clear()


func add_player(id: int, input_type: String, device: int) -> void:
	players.append({
		"id": id,
		"type": input_type,
		"device": device
	})
	
	print("Player: ", id, " added with type: ", input_type, " and device: ", device)


func get_player_count() -> int:
	return players.size()
