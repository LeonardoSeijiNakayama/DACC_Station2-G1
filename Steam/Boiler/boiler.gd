extends Node
class_name Boiler

@onready var sendSteamTimer:Timer = $SendSteamTimer
@onready var generateSteamTimer:Timer = $GenerateSteamTimer
@onready var animation:AnimatedSprite2D = $AnimatedSprite2D

@export_range(0.0, 100.0, 5.0) var capacity:float= 0.0
@export_range(0.0, 100.0, 5.0) var coal_capacity:float= 0.0
@export var id_destination:Array[int] = []

var can_receive:bool = true

const amount_constant:float = 10.0
const amount_generate_constant:float = 20.0

const WORKING = 1
const NOT_WORKING = 2 

var current_state = NOT_WORKING

var destination_valves: Array[SteamValve] = []


func _ready() -> void:
	add_to_group("steam")
	find_destination_valves()


func _physics_process(_delta: float) -> void:
	if coal_capacity <= 0.0:
		current_state = NOT_WORKING
		animation.play("NotWorking")
	
	if generateSteamTimer.is_stopped() and coal_capacity>=amount_generate_constant:
		current_state = WORKING
		generate_steam(amount_generate_constant)
		generateSteamTimer.start()
		animation.play("Working")
	
	if sendSteamTimer.is_stopped() and capacity>=amount_constant:
		send_steam(amount_constant)
		sendSteamTimer.start()


func find_destination_valves() -> void:
	destination_valves.clear()
	
	for node in get_tree().get_nodes_in_group("steam"):
		if node is SteamValve:
			if id_destination.has(node.id):
				destination_valves.append(node)
	
	if destination_valves.is_empty():
		print("Caldeira não encontrou nenhuma válvula destino.")
	else:
		print("Caldeira encontrou ", destination_valves.size(), " válvula(s) destino.")


func send_steam(amount: float) -> void:
	if destination_valves.is_empty():
		return
	
	if capacity <= 0.0:
		return
	
	var available_valves: Array[SteamValve] = []
	
	for valve in destination_valves:
		if valve is SteamValve and valve.capacity < 100.0:
			available_valves.append(valve)
	
	if available_valves.is_empty():
		return
	
	var steam_to_send: float = min(amount, capacity)
	var amount_per_valve: float = steam_to_send / available_valves.size()
	
	capacity -= steam_to_send
	
	for valve in available_valves:
		valve.receive_steam(amount_per_valve)


func receive_coal(amount:float)->void:
	coal_capacity += amount


func generate_steam(amount:float)->void:
	coal_capacity-=amount
	capacity+=amount
