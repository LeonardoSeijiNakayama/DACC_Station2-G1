extends Node2D
class_name SteamGun

@onready var valveAnimation:AnimatedSprite2D = $ValveSprite
@onready var attackTimer:Timer = $AttackTimer
@onready var attackingTimer:Timer = $AttackingTimer
@onready var shortAttackArea:Area2D = $ShortAttackArea
@onready var mediumAttackArea:Area2D = $MediumAttackArea
@onready var longAttackArea:Area2D = $LongAttackArea
@onready var shortAttackAnimation:AnimatedSprite2D = $ShortAttackSprite
@onready var mediumAttackAnimation:AnimatedSprite2D = $MediumAttackSprite
@onready var longAttackAnimation:AnimatedSprite2D = $LongAttackSprite
@onready var capacityBar:ProgressBar = $ProgressBar

@export var id = 0
@export_range(0.0, 100.0) var capacity = 0.0

const OPENED = 1
const CLOSED = 2

var current_state = OPENED

func _ready() -> void:
	add_to_group("steam")
	shortAttackArea.monitoring = false
	mediumAttackArea.monitoring = false
	longAttackArea.monitoring = false
	shortAttackAnimation.visible = false
	mediumAttackAnimation.visible = false
	longAttackAnimation.visible = false

func _process(_delta: float) -> void:
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

func longAttack():
	capacity-=100.0
	capacityBar.set_value_no_signal(capacity)
	longAttackArea.monitoring = true
	longAttackAnimation.visible = true
	longAttackAnimation.play("Attack")
	attackingTimer.start()

func mediumAttack():
	capacity-=66.0
	capacityBar.set_value_no_signal(capacity)
	mediumAttackArea.monitoring = true
	mediumAttackAnimation.visible = true
	mediumAttackAnimation.play("Attack")
	attackingTimer.start()

func shortAttack():
	capacity-=33.0
	capacityBar.set_value_no_signal(capacity)
	shortAttackArea.monitoring = true
	shortAttackAnimation.visible = true
	shortAttackAnimation.play("Attack")
	attackingTimer.start()

func receive_steam(amount: float) -> void:
	capacity = min(capacity + amount, 100.0)
	capacityBar.set_value_no_signal(capacity)

func open_valve() -> void:
	valveAnimation.play("Opening")
	current_state = OPENED

func close_valve() -> void:
	valveAnimation.play("Closing")
	current_state = CLOSED

func _on_attacking_timer_timeout() -> void:
	shortAttackArea.monitoring = false
	mediumAttackArea.monitoring = false
	longAttackArea.monitoring = false


func _on_short_attack_sprite_animation_finished() -> void:
	shortAttackAnimation.visible = false
	pass


func _on_medium_attack_sprite_animation_finished() -> void:
	mediumAttackAnimation.visible = false
	pass


func _on_long_attack_sprite_animation_finished() -> void:
	longAttackAnimation.visible = false
	pass
