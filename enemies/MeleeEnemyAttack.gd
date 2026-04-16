extends Node
class_name  MeleeEnemyAttack

@onready var _melee_attack_timer = $MeleeAttackTimer
@onready var _movement:EnemyMovement = $"../Movement"
var base_in_range = false
var base_ref = null

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Base"):
		_movement.stopped_area = true
		base_in_range = true
		base_ref = body
		if _melee_attack_timer.is_stopped():
			_melee_attack_timer.start()


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Base"):
		_movement.stopped_area = false
		base_in_range = false
		base_ref = null
		_melee_attack_timer.stop()




func _on_attack_timer_timeout() -> void:
	if base_in_range and is_instance_valid(base_ref):
		attack()



func attack()->void:
	var base_health:BaseHealth = base_ref.get_node("Health")
	if base_health:
		base_health.take_damage(2.0)
