extends Node
class_name SteamValve


@onready var sendSteamTimer: Timer = $SendSteamTimer
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var capacityBar: TextureProgressBar = $ProgressBar


@export_range(0.0, 100.0, 5.0) var capacity: float = 0.0
@export var id := 0
@export var id_destination: Array[int] = []

@export_range(5.0, 100.0, 5.0) var amount_constant: float = 5.0


const OPENED := 1
const CLOSED := 2


var can_receive: bool = true
var current_state := CLOSED
var destination_valves: Array[Node] = []


var outlined := false:
	set(value):
		if outlined == value:
			return
		
		outlined = value
		update_outline_animation()


func _ready() -> void:
	capacityBar.value = capacity

	sendSteamTimer.one_shot = true
	sendSteamTimer.timeout.connect(_on_send_steam_timer_timeout)

	add_to_group("steam")
	call_deferred("find_destination_valves")

	update_rest_animation()
	_try_start_cooldown()


func find_destination_valves() -> void:
	destination_valves.clear()
	
	for valve in get_tree().get_nodes_in_group("steam"):
		if valve is SteamValve and valve.id in id_destination:
			destination_valves.append(valve)
		
		if valve is SteamGun and valve.id in id_destination:
			destination_valves.append(valve)
	
	if destination_valves.is_empty():
		print("Nenhuma válvula destino encontrada para a válvula ", id)


func send_steam(amount: float) -> void:
	if current_state == CLOSED:
		return
	
	if destination_valves.is_empty():
		return
	
	if capacity <= 0.0:
		return
	
	var available_valves: Array[Node] = []
	
	for valve in destination_valves:
		if valve.capacity < 100.0:
			available_valves.append(valve)
	
	if available_valves.is_empty():
		return
	
	var steam_to_send: float = min(amount, capacity)
	var amount_per_valve: float = steam_to_send / available_valves.size()
	
	capacity -= steam_to_send
	capacityBar.value = capacity
	
	for valve in available_valves:
		valve.receive_steam(amount_per_valve)


func receive_steam(amount: float) -> void:
	capacity = min(capacity + amount, 100.0)
	capacityBar.value = capacity
	_try_start_cooldown()


func open_valve() -> void:
	if current_state == OPENED:
		return
	
	if outlined:
		animation.play("OpeningOutlined")
	else:
		animation.play("Opening")
	
	await animation.animation_finished
	
	current_state = OPENED
	update_rest_animation()
	
	if sendSteamTimer.is_stopped():
		_try_start_cooldown()


func close_valve() -> void:
	if current_state == CLOSED:
		return
	
	if outlined:
		animation.play("ClosingOutlined")
	else:
		animation.play("Closing")
	
	await animation.animation_finished
	
	current_state = CLOSED
	update_rest_animation()
	
	if sendSteamTimer.is_stopped():
		_try_start_cooldown()


func update_outline_animation() -> void:
	if not is_node_ready():
		return
	
	if animation.is_playing():
		var new_animation := get_equivalent_transition_animation()
		
		if new_animation == "":
			return
		
		if animation.animation == new_animation:
			return
		
		change_animation_keeping_frame(new_animation)
		return
	
	
	update_rest_animation()


func get_equivalent_transition_animation() -> String:
	match animation.animation:
		"Opening":
			if outlined:
				return "OpeningOutlined"
			else:
				return "Opening"
		
		"OpeningOutlined":
			if outlined:
				return "OpeningOutlined"
			else:
				return "Opening"
		
		"Closing":
			if outlined:
				return "ClosingOutlined"
			else:
				return "Closing"
		
		"ClosingOutlined":
			if outlined:
				return "ClosingOutlined"
			else:
				return "Closing"
	
	return ""


func change_animation_keeping_frame(new_animation: String) -> void:
	var old_frame := animation.frame
	var old_progress := animation.frame_progress
	
	animation.play(new_animation)
	
	var frame_count := animation.sprite_frames.get_frame_count(new_animation)
	old_frame = clampi(old_frame, 0, frame_count - 1)
	
	animation.set_frame_and_progress(old_frame, old_progress)


func update_rest_animation() -> void:
	var target_animation := ""
	var target_frame := 0
	
	if current_state == CLOSED:
		if outlined:
			target_animation = "OpeningOutlined"
		else:
			target_animation = "Opening"
		
		target_frame = 0
	
	else:
		if outlined:
			target_animation = "OpeningOutlined"
		else:
			target_animation = "Opening"
		
		target_frame = animation.sprite_frames.get_frame_count(target_animation) - 1
	
	animation.animation = target_animation
	animation.set_frame_and_progress(target_frame, 0.0)
	animation.pause()


func _try_start_cooldown() -> void:
	if current_state == CLOSED:
		return
	
	if sendSteamTimer.is_stopped() and capacity >= amount_constant:
		sendSteamTimer.start()


func _on_send_steam_timer_timeout() -> void:
	if current_state == OPENED and capacity >= amount_constant:
		send_steam(amount_constant)
	
	_try_start_cooldown()
