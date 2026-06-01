extends Node
class_name Boiler

@onready var sendSteamTimer:Timer = $SendSteamTimer
@onready var generateSteamTimer:Timer = $GenerateSteamTimer
@onready var animation:AnimatedSprite2D = $AnimatedSprite2D
@onready var fireBar:TextureProgressBar = $TextureProgressBar
@onready var waterBar:TextureProgressBar = $TextureProgressBar2
@onready var steamBar:TextureProgressBar = $TextureProgressBar3

@export_range(0.0, 100.0, 5.0) var capacity:float= 0.0
@export_range(0.0, 100.0, 5.0) var coal_capacity:float= 0.0
@export_range(0.0, 100.0, 5.0) var water_capacity:float = 0.0
@export var id_destination:Array[int] = []

var can_receive:bool = true

const amount_send_constant:float = 10.0
const steam_generate_amount:float = 10.0
const coal_amount = 20.0
const coal_generate_amount = 20.0
const water_amount = 20.0
const water_generate_amount = 10.0

const WORKING = 1
const NOT_WORKING = 2 

var current_state = NOT_WORKING

var destination_valves: Array[SteamValve] = []


func _ready() -> void:
	add_to_group("steam")
	find_destination_valves()


func _physics_process(_delta: float) -> void:
	
	fireBar.value = coal_capacity
	waterBar.value = water_capacity
	steamBar.value = capacity
	
	if (coal_capacity <= 0.0 or water_capacity <= 0.0) and capacity<=0.0:
		current_state = NOT_WORKING
		animation.play("NotWorking")
	
	if generateSteamTimer.is_stopped() and water_capacity>=water_generate_amount and coal_capacity>=coal_generate_amount and capacity < 100.0:
		current_state = WORKING
		generate_steam()
		generateSteamTimer.start()
		animation.play("Working")
	
	if sendSteamTimer.is_stopped() and capacity>=amount_send_constant:
		send_steam(amount_send_constant)
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


func receive_coal()->void:
	coal_capacity += coal_amount


func receive_water()->void:
	water_capacity += water_amount


func generate_steam()->void:
	water_capacity-=water_generate_amount
	coal_capacity-=coal_generate_amount
	capacity = min(capacity + steam_generate_amount, 100.0)
