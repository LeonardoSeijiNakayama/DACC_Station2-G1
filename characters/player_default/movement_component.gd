extends Node
class_name PlayerMovement


@export var walk_speed := 100.0
@export var run_speed := 600.0
@export var jump_velocity := -275.0
@export var gravity := 700.0
@export var dash_speed := 400.0
@export var joy_deadzone := 0.15

var current_speed := 100.0
var is_dashing := false
var is_on_ladder := false
var climbing := false

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
	JOY_BUTTON_A,
	JOY_BUTTON_B
]

@onready var dash_timer: Timer = get_node_or_null("../Dash_timer")


func _ready() -> void:
	if dash_timer != null:
		var callable := Callable(self, "_on_dash_timer_timeout")

		if not dash_timer.timeout.is_connected(callable):
			dash_timer.timeout.connect(callable)


func setup_input(profile: Dictionary, single_player: bool = false) -> void:
	input_profile = profile
	is_single = single_player
	
	joy_buttons_previous.clear()
	joy_buttons_current.clear()
	any_joy_buttons_previous.clear()
	any_joy_buttons_current.clear()


func physics_update(player: CharacterBody2D, delta: float) -> void:
	update_joy_button_states()
	
	update_run_speed()
	update_dash(player)
	update_jump(player)
	update_ladder(player)
	update_gravity(player, delta)
	update_horizontal_movement(player)


func update_run_speed() -> void:
	if is_dash_pressed() and not is_dashing:
		current_speed = run_speed
	else:
		current_speed = walk_speed


func update_dash(player: CharacterBody2D) -> void:
	if is_dash_just_pressed() and player.is_on_floor():
		is_dashing = true
	
		if dash_timer != null:
			dash_timer.start()


func update_jump(player: CharacterBody2D) -> void:
	if is_jump_just_pressed() and player.is_on_floor():
		player.velocity.y = jump_velocity


func update_ladder(player: CharacterBody2D) -> void:
	if is_on_ladder and is_up_pressed():
		climbing = true
	
	if is_jump_just_pressed() or not is_on_ladder:
		climbing = false
	
	if not climbing:
		return
	
	var vertical_direction := get_vertical_axis()
	
	if vertical_direction != 0:
		if is_dashing:
			player.velocity.y = vertical_direction * dash_speed
		else:
			player.velocity.y = vertical_direction * current_speed
	else:
		player.velocity.y = move_toward(player.velocity.y, 0.0, current_speed)


func update_gravity(player: CharacterBody2D, delta: float) -> void:
	if not player.is_on_floor() and not climbing:
		player.velocity.y += gravity * delta


func update_horizontal_movement(player: CharacterBody2D) -> void:
	var direction := get_horizontal_axis()
	
	if direction != 0 and not climbing:
		if is_dashing:
			player.velocity.x = direction * dash_speed
		else:
			player.velocity.x = direction * current_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, current_speed)


func set_on_ladder(value: bool) -> void:
	is_on_ladder = value
	
	if not is_on_ladder:
		climbing = false


func _on_dash_timer_timeout() -> void:
	is_dashing = false



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


func get_horizontal_axis() -> float:
	if is_single:
		var keyboard_value := Input.get_axis("Esquerda", "Direita")
		var joy_value := get_any_joy_axis(JOY_AXIS_LEFT_X)
	
		if abs(keyboard_value) > 0.0:
			return keyboard_value
	
		if abs(joy_value) > joy_deadzone:
			return joy_value
	
		return 0.0
	
	if is_keyboard():
		return Input.get_axis("Esquerda", "Direita")
	
	if is_joypad():
		var value := Input.get_joy_axis(get_device(), JOY_AXIS_LEFT_X)
	
		if abs(value) < joy_deadzone:
			return 0.0
	
		return value
	
	return 0.0


func get_vertical_axis() -> float:
	if is_single:
		var keyboard_value := Input.get_axis("Cima", "Baixo")
		var joy_value := get_any_joy_axis(JOY_AXIS_LEFT_Y)
	
		if abs(keyboard_value) > 0.0:
			return keyboard_value
	
		if abs(joy_value) > joy_deadzone:
			return joy_value
	
		return 0.0
	
	if is_keyboard():
		return Input.get_axis("Cima", "Baixo")
	
	if is_joypad():
		var value := Input.get_joy_axis(get_device(), JOY_AXIS_LEFT_Y)
	
		if abs(value) < joy_deadzone:
			return 0.0
	
		return value
	
	return 0.0


func get_any_joy_axis(axis: JoyAxis) -> float:
	for device in Input.get_connected_joypads():
		var value := Input.get_joy_axis(device, axis)
	
		if abs(value) > joy_deadzone:
			return value
	
	return 0.0


func is_up_pressed() -> bool:
	if is_single:
		return Input.is_action_pressed("Cima") or get_vertical_axis() < -joy_deadzone
	
	if is_keyboard():
		return Input.is_action_pressed("Cima")
	
	if is_joypad():
		return get_vertical_axis() < -joy_deadzone
	
	return false


func is_dash_pressed() -> bool:
	if is_single:
		return Input.is_action_pressed("Dash") or is_any_joy_button_pressed(JOY_BUTTON_B)
	
	if is_keyboard():
		return Input.is_action_pressed("Dash")
	
	if is_joypad():
		return Input.is_joy_button_pressed(get_device(), JOY_BUTTON_B)
	
	return false


func is_dash_just_pressed() -> bool:
	if is_single:
		return Input.is_action_just_pressed("Dash") or is_any_joy_button_just_pressed(JOY_BUTTON_B)
	
	if is_keyboard():
		return Input.is_action_just_pressed("Dash")
	
	if is_joypad():
		return is_joy_button_just_pressed(JOY_BUTTON_B)
	
	return false


func is_jump_just_pressed() -> bool:
	if is_single:
		return Input.is_action_just_pressed("Pulo") or is_any_joy_button_just_pressed(JOY_BUTTON_A)
	
	if is_keyboard():
		return Input.is_action_just_pressed("Pulo")
	
	if is_joypad():
		return is_joy_button_just_pressed(JOY_BUTTON_A)
	
	return false


func is_joy_button_pressed(button: JoyButton) -> bool:
	return joy_buttons_current.get(button, false)


func is_joy_button_just_pressed(button: JoyButton) -> bool:
	var current: bool = joy_buttons_current.get(button, false)
	var previous: bool = joy_buttons_previous.get(button, false)
	
	return current and not previous


func is_any_joy_button_pressed(button: JoyButton) -> bool:
	return any_joy_buttons_current.get(button, false)


func is_any_joy_button_just_pressed(button: JoyButton) -> bool:
	var current: bool = any_joy_buttons_current.get(button, false)
	var previous: bool = any_joy_buttons_previous.get(button, false)
	
	return current and not previous
