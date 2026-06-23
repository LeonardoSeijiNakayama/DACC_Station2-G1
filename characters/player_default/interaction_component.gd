extends Node
class_name PlayerInteraction


@export var area_player_path: NodePath = NodePath("../Area_Player")

@onready var area_player: Area2D = get_node(area_player_path)
@onready var item_position: Node2D = $"../ItemPosition"

var holding := false
var item_hold_id: RigidBody2D = null

var mine_reference: Mine = null
var mining := false

var is_single := false

var input_profile: Dictionary = {
	"id": 1,
	"type": "keyboard",
	"device": -1
}

var joy_buttons_previous: Dictionary = {}
var joy_buttons_current: Dictionary = {}

var any_joy_buttons_previous: Dictionary = {}
var any_joy_buttons_current: Dictionary = {}

const TRACKED_JOY_BUTTONS := [
	JOY_BUTTON_X
]

const ITENS_GRUPO := ["Area_Carvao", "Area_Balde"]


func setup_input(profile: Dictionary, single_player: bool = false) -> void:
	input_profile = profile
	is_single = single_player

	joy_buttons_previous.clear()
	joy_buttons_current.clear()
	any_joy_buttons_previous.clear()
	any_joy_buttons_current.clear()


func physics_update(player: CharacterBody2D) -> void:
	update_joy_button_states()

	sync_mining_state(player)

	if holding:
		update_held_item()
		handle_holding_interaction(player)
	else:
		handle_empty_hand_interaction(player)

	handle_mining_release(player)


func update_held_item() -> void:
	if item_hold_id == null or not is_instance_valid(item_hold_id):
		item_hold_id = null
		holding = false
		return

	item_hold_id.global_position = item_position.global_position


func handle_holding_interaction(player: CharacterBody2D) -> void:
	if not is_interact_just_pressed():
		return

	var closest_area := get_closest_interactable_area(player, false, true)

	if closest_area == null:
		drop_item()
		return

	if closest_area is BoilerArea and item_hold_id.has_node("Area_Carvao"):
		var boiler_reference: Boiler = closest_area.get_parent()
		boiler_reference.receive_coal()

		item_hold_id.queue_free()
		item_hold_id = null
		holding = false

	elif closest_area is WaterPitArea \
	and item_hold_id.has_node("Area_Balde") \
	and not item_hold_id.is_filled:
		item_hold_id.get_filled()

	elif closest_area is BoilerArea \
	and item_hold_id.has_node("Area_Balde") \
	and item_hold_id.is_filled:
		var boiler_reference: Boiler = closest_area.get_parent()
		boiler_reference.receive_water()
		item_hold_id.empty()

	else:
		drop_item()


func handle_empty_hand_interaction(player: CharacterBody2D) -> void:
	if not is_interact_just_pressed():
		return

	var closest_area := get_closest_interactable_area(player, true, true)

	if closest_area == null:
		return

	if is_item_area(closest_area):
		pick_item(closest_area)

	elif closest_area is ValveArea:
		var valve_reference: SteamValve = closest_area.get_parent()

		if valve_reference.current_state == SteamValve.CLOSED:
			valve_reference.open_valve()
		else:
			valve_reference.close_valve()

	elif closest_area is GunValveArea:
		var gun_reference: SteamGun = closest_area.get_parent()

		if gun_reference.current_state == SteamGun.CLOSED:
			gun_reference.open_valve()
		else:
			gun_reference.close_valve()

	elif closest_area is MineArea:
		mine_reference = closest_area.get_parent()
		mining = true
		mine_reference.start_production(player)


func handle_mining_release(player: CharacterBody2D) -> void:
	if is_interact_just_released() and mining:
		stop_current_mining(player)


func stop_current_mining(player: CharacterBody2D) -> void:
	if mine_reference != null and is_instance_valid(mine_reference):
		mine_reference.stop_production(player)

	mine_reference = null
	mining = false


func sync_mining_state(player: CharacterBody2D) -> void:
	if not mining:
		return

	if mine_reference == null or not is_instance_valid(mine_reference):
		mine_reference = null
		mining = false
		return

	# Caso a mina tenha parado esse player por outro motivo,
	# por exemplo ele saiu da área da mina.
	if not mine_reference.is_miner_active(player):
		mine_reference = null
		mining = false


func pick_item(area: Area2D) -> void:
	item_hold_id = area.get_parent() as RigidBody2D

	if item_hold_id == null:
		return

	item_hold_id.rotation = 0
	item_hold_id.freeze = true
	holding = true


func drop_item() -> void:
	if item_hold_id != null and is_instance_valid(item_hold_id):
		item_hold_id.freeze = false

	item_hold_id = null
	holding = false


func is_item_area(area: Area2D) -> bool:
	return area.name in ITENS_GRUPO


func is_station_area(area: Area2D) -> bool:
	return area is BoilerArea \
		or area is WaterPitArea \
		or area is ValveArea \
		or area is GunValveArea \
		or area is MineArea


func get_closest_interactable_area(
	player: CharacterBody2D,
	include_items := true,
	include_stations := true
) -> Area2D:
	var closest_area: Area2D = null
	var closest_distance := INF

	for area in area_player.get_overlapping_areas():
		var is_valid := false

		if include_items and is_item_area(area):
			is_valid = true

		if include_stations and is_station_area(area):
			is_valid = true

		if not is_valid:
			continue

		if holding and item_hold_id != null and area.get_parent() == item_hold_id:
			continue

		var distance := player.global_position.distance_to(area.global_position)

		if distance < closest_distance:
			closest_distance = distance
			closest_area = area

	return closest_area


# =========================
# INPUT HELPERS
# =========================

func is_keyboard() -> bool:
	return input_profile.get("type", "keyboard") == "keyboard"


func is_joypad() -> bool:
	return input_profile.get("type", "keyboard") == "joypad"


func get_device() -> int:
	return input_profile.get("device", -1)


func update_joy_button_states() -> void:
	joy_buttons_previous = joy_buttons_current.duplicate()
	any_joy_buttons_previous = any_joy_buttons_current.duplicate()

	joy_buttons_current.clear()
	any_joy_buttons_current.clear()

	var device := get_device()

	for button in TRACKED_JOY_BUTTONS:
		var current_for_device := false

		if device >= 0:
			current_for_device = Input.is_joy_button_pressed(device, button)

		joy_buttons_current[button] = current_for_device

		var current_for_any_device := false

		for connected_device in Input.get_connected_joypads():
			if Input.is_joy_button_pressed(connected_device, button):
				current_for_any_device = true
				break

		any_joy_buttons_current[button] = current_for_any_device


func is_interact_just_pressed() -> bool:
	if is_single:
		return Input.is_action_just_pressed("Interagir") or is_any_joy_button_just_pressed(JOY_BUTTON_X)

	if is_keyboard():
		return Input.is_action_just_pressed("Interagir")

	if is_joypad():
		return is_joy_button_just_pressed(JOY_BUTTON_X)

	return false


func is_interact_just_released() -> bool:
	if is_single:
		return Input.is_action_just_released("Interagir") or is_any_joy_button_just_released(JOY_BUTTON_X)

	if is_keyboard():
		return Input.is_action_just_released("Interagir")

	if is_joypad():
		return is_joy_button_just_released(JOY_BUTTON_X)

	return false


func is_joy_button_just_pressed(button: JoyButton) -> bool:
	var current: bool = joy_buttons_current.get(button, false)
	var previous: bool = joy_buttons_previous.get(button, false)

	return current and not previous


func is_joy_button_just_released(button: JoyButton) -> bool:
	var current: bool = joy_buttons_current.get(button, false)
	var previous: bool = joy_buttons_previous.get(button, false)

	return not current and previous


func is_any_joy_button_just_pressed(button: JoyButton) -> bool:
	var current: bool = any_joy_buttons_current.get(button, false)
	var previous: bool = any_joy_buttons_previous.get(button, false)

	return current and not previous


func is_any_joy_button_just_released(button: JoyButton) -> bool:
	var current: bool = any_joy_buttons_current.get(button, false)
	var previous: bool = any_joy_buttons_previous.get(button, false)

	return not current and previous


func _exit_tree() -> void:
	var player := get_parent() as CharacterBody2D

	if player != null and mining:
		stop_current_mining(player)
