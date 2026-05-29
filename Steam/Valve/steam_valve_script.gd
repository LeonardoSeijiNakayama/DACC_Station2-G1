extends Node
class_name SteamValve

@onready var sendSteamTimer: Timer = $SendSteamTimer
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var capacityBar: TextureProgressBar = $ProgressBar

@export_range(0.0, 100.0, 5.0) var capacity: float = 0.0
@export var id := 0
@export var id_destination: Array[int] = []

var can_receive: bool = true

const OPENED := 1
const CLOSED := 2

const amount_constant: float = 5.0

var current_state := OPENED
var destination_valves: Array[Node] = []


func _ready() -> void:
	capacityBar.value = capacity

	sendSteamTimer.one_shot = true
	sendSteamTimer.timeout.connect(_on_send_steam_timer_timeout)

	add_to_group("steam")
	call_deferred("find_destination_valves")

	_try_start_cooldown()


func _physics_process(_delta: float) -> void:
	pass


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
	print("Valvula ", id, " recebeu vapor")
	capacity = min(capacity + amount, 100.0)
	capacityBar.value = capacity
	_try_start_cooldown()


func open_valve() -> void:
	animation.play("Opening")
	current_state = OPENED


func close_valve() -> void:
	animation.play("Closing")
	current_state = CLOSED


func _try_start_cooldown() -> void:
	if current_state == CLOSED:
		return
	
	if sendSteamTimer.is_stopped() and capacity >= amount_constant:
		sendSteamTimer.start()


func _on_send_steam_timer_timeout() -> void:
	if current_state == OPENED and capacity >= amount_constant:
		send_steam(amount_constant)
	
	_try_start_cooldown()
