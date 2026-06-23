extends Node2D
class_name SteamGun


@onready var valveAnimation: AnimatedSprite2D = $AnimatedSprite2D
@onready var attackTimer: Timer = $AttackTimer
@onready var attackingTimer: Timer = $AttackingTimer
@onready var shortAttackArea: Area2D = $ShortAttackArea
@onready var mediumAttackArea: Area2D = $MediumAttackArea
@onready var longAttackArea: Area2D = $LongAttackArea
@onready var shortAttackAnimation: AnimatedSprite2D = $ShortAttackSprite
@onready var mediumAttackAnimation: AnimatedSprite2D = $MediumAttackSprite
@onready var longAttackAnimation: AnimatedSprite2D = $LongAttackSprite
@onready var capacityBar: TextureProgressBar = $ProgressBar


@export var id := 0
@export_range(0.0, 100.0) var capacity := 0.0


const OPENED := 1
const CLOSED := 2


var current_state := CLOSED


var outlined := false:
	set(value):
		if outlined == value:
			return
		
		outlined = value
		update_outline_animation()


func _ready() -> void:
	add_to_group("steam")
	
	shortAttackArea.monitoring = false
	mediumAttackArea.monitoring = false
	longAttackArea.monitoring = false
	
	shortAttackAnimation.visible = false
	mediumAttackAnimation.visible = false
	longAttackAnimation.visible = false
	
	update_rest_animation()


func _process(_delta: float) -> void:
	capacityBar.value = capacity
	
	if current_state == OPENED and attackTimer.is_stopped():
		if capacity >= 100.0:
			longAttack()
			attackTimer.start()
		elif capacity >= 66.0:
			mediumAttack()
			attackTimer.start()
		elif capacity >= 33.0:
			shortAttack()
			attackTimer.start()


func longAttack() -> void:
	capacity -= 100.0
	
	longAttackArea.monitoring = true
	longAttackAnimation.visible = true
	longAttackAnimation.play("Attack")
	
	attackingTimer.start()


func mediumAttack() -> void:
	capacity -= 66.0
	
	mediumAttackArea.monitoring = true
	mediumAttackAnimation.visible = true
	mediumAttackAnimation.play("Attack")
	
	attackingTimer.start()


func shortAttack() -> void:
	capacity -= 33.0
	
	shortAttackArea.monitoring = true
	shortAttackAnimation.visible = true
	shortAttackAnimation.play("Attack")
	
	attackingTimer.start()


func receive_steam(amount: float) -> void:
	capacity = min(capacity + amount, 100.0)


func open_valve() -> void:
	if current_state == OPENED:
		return
	
	if outlined:
		valveAnimation.play("OpeningOutlined")
	else:
		valveAnimation.play("Opening")
	
	await valveAnimation.animation_finished
	
	current_state = OPENED
	update_rest_animation()


func close_valve() -> void:
	if current_state == CLOSED:
		return
	
	if outlined:
		valveAnimation.play("ClosingOutlined")
	else:
		valveAnimation.play("Closing")
	
	await valveAnimation.animation_finished
	
	current_state = CLOSED
	update_rest_animation()


func update_outline_animation() -> void:
	if not is_node_ready():
		return
	
	if valveAnimation.is_playing():
		var new_animation := get_equivalent_transition_animation()
		
		if new_animation == "":
			return
		
		if valveAnimation.animation == new_animation:
			return
		
		change_animation_keeping_frame(new_animation)
		return
	
	update_rest_animation()


func get_equivalent_transition_animation() -> String:
	match valveAnimation.animation:
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
	var old_frame := valveAnimation.frame
	var old_progress := valveAnimation.frame_progress
	
	valveAnimation.play(new_animation)
	
	var frame_count := valveAnimation.sprite_frames.get_frame_count(new_animation)
	old_frame = clampi(old_frame, 0, frame_count - 1)
	
	valveAnimation.set_frame_and_progress(old_frame, old_progress)


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
		
		target_frame = valveAnimation.sprite_frames.get_frame_count(target_animation) - 1
	
	valveAnimation.animation = target_animation
	valveAnimation.set_frame_and_progress(target_frame, 0.0)
	valveAnimation.pause()


func _on_attacking_timer_timeout() -> void:
	shortAttackArea.monitoring = false
	mediumAttackArea.monitoring = false
	longAttackArea.monitoring = false


func _on_short_attack_sprite_animation_finished() -> void:
	shortAttackAnimation.visible = false


func _on_medium_attack_sprite_animation_finished() -> void:
	mediumAttackAnimation.visible = false


func _on_long_attack_sprite_animation_finished() -> void:
	longAttackAnimation.visible = false


func _on_short_attack_area_area_entered(area: Area2D) -> void:
	area.get_parent().get_node("Health").take_damage(100.0)


func _on_medium_attack_area_area_entered(area: Area2D) -> void:
	area.get_parent().get_node("Health").take_damage(100.0)


func _on_long_attack_area_area_entered(area: Area2D) -> void:
	area.get_parent().get_node("Health").take_damage(100.0)
