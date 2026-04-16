extends Node
class_name RangedEnemyAttack

@onready var _movement = $"../Movement"
@onready var _ranged_attack_timer = $RangedAttackTimer
@onready var _animation = $"../Animation"

var base_ref = null
var base_in_range = false

func ranged_attack()->void:
	_animation.play_attack_animation()
	var base_health:BaseHealth = base_ref.get_node("Health")
	if base_health:
		base_health.take_damage(1.0)

func _on_ranged_attack_timer_timeout() -> void:
	if base_in_range and is_instance_valid(base_ref) and _movement.stopped:
		ranged_attack()


func _on_attack_area_ranged_body_entered(body: Node2D) -> void:
	if body.is_in_group("Base"):
		base_in_range = true
		base_ref = body
		if _ranged_attack_timer.is_stopped():
			_ranged_attack_timer.start()


func _on_attack_area_ranged_body_exited(body: Node2D) -> void:
	if body.is_in_group("Base"):
		base_in_range = false
		base_ref = null
		_ranged_attack_timer.stop()
