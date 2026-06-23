extends Node
class_name Boiler

@onready var sendSteamTimer: Timer = $SendSteamTimer
@onready var generateSteamTimer: Timer = $GenerateSteamTimer
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var fireBar: TextureProgressBar = $TextureProgressBar
@onready var waterBar: TextureProgressBar = $TextureProgressBar2
@onready var steamBar: TextureProgressBar = $TextureProgressBar3

@export_range(0.0, 100.0, 5.0) var capacity: float = 0.0
@export_range(0.0, 100.0, 5.0) var coal_capacity: float = 0.0
@export_range(0.0, 100.0, 5.0) var water_capacity: float = 0.0
@export var id_destination: Array[int] = []

var can_receive: bool = true

const amount_send_constant: float = 10.0
const steam_generate_amount: float = 10.0
const coal_amount = 40.0
const coal_generate_amount = 10.0
const water_amount = 40.0
const water_generate_amount = 10.0

const WORKING = 1
const NOT_WORKING = 2 

var current_state = NOT_WORKING:
	set(value):
		if current_state == value:
			return
		
		current_state = value
		update_animation()

var outlined := false:
	set(value):
		if outlined == value:
			return
		
		outlined = value
		update_animation()

var destination_valves: Array[SteamValve] = []


func _ready() -> void:
	add_to_group("steam")
	find_destination_valves()
	update_animation()


func _physics_process(_delta: float) -> void:
	fireBar.value = coal_capacity
	waterBar.value = water_capacity
	steamBar.value = capacity
	
	if (coal_capacity <= 0.0 or water_capacity <= 0.0) and capacity <= 0.0:
		current_state = NOT_WORKING
	
	if generateSteamTimer.is_stopped() and water_capacity >= water_generate_amount and coal_capacity >= coal_generate_amount and capacity < 100.0:
		current_state = WORKING
		generate_steam()
		generateSteamTimer.start()
	
	if sendSteamTimer.is_stopped() and capacity >= amount_send_constant:
		send_steam(amount_send_constant)
		sendSteamTimer.start()


func update_animation() -> void:
	if not is_node_ready():
		return
	
	var new_animation := ""
	
	if current_state == WORKING:
		if outlined:
			new_animation = "WorkingOutlined"
		else:
			new_animation = "Working"
	else:
		if outlined:
			new_animation = "NotWorkingOutlined"
		else:
			new_animation = "NotWorking"
	
	if animation.animation != new_animation:
		var old_frame := animation.frame
		var old_progress := animation.frame_progress
		
		animation.play(new_animation)
		
		var frame_count := animation.sprite_frames.get_frame_count(new_animation)
		old_frame = clampi(old_frame, 0, frame_count - 1)
		
		animation.set_frame_and_progress(old_frame, old_progress)


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


func receive_coal() -> void:
	coal_capacity = min(coal_capacity + coal_amount, 100.0)


func receive_water() -> void:
	water_capacity = min(water_capacity + water_amount, 100.0)


func generate_steam() -> void:
	water_capacity -= water_generate_amount
	coal_capacity -= coal_generate_amount
	capacity = min(capacity + steam_generate_amount, 100.0)
