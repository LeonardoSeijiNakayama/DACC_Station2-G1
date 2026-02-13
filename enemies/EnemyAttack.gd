extends Node
class_name  EnemyAttack

@onready var _melee_attack_range = $"../AttackAreaMelee"
@onready var _melee_attack_timer = $MeleeAttackTimer
@onready var _ranged_attack_range = $"../AttackAreaRanged"
@onready var _ranged_attack_timer = $RangedAttackTimer
@onready var _skin:MeshInstance2D = $"../MeshInstance2D"

var type = 1
var base_in_range = false
var base_ref:StaticBody2D = null


func _ready() -> void:
	match type:
		1:
			_melee_attack_range.monitoring = true
			_melee_attack_range.monitorable = true
			_ranged_attack_range.monitoring = false
			_ranged_attack_range.monitorable = false
			_skin.modulate = Color(1.0, 0.0, 0.0, 1.0)
		2: 
			_melee_attack_range.monitoring = false
			_melee_attack_range.monitorable = false
			_ranged_attack_range.monitoring = true
			_ranged_attack_range.monitorable = true
			_skin.modulate = Color(0.0, 1.0, 0.0, 1.0)




func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Base"):
		base_in_range = true
		base_ref = body
		if _melee_attack_timer.is_stopped():
			_melee_attack_timer.start()


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Base"):
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


func ranged_attack()->void:
	var base_health:BaseHealth = base_ref.get_node("Health")
	if base_health:
		base_health.take_damage(1.0)

func _on_ranged_attack_timer_timeout() -> void:
	if base_in_range and is_instance_valid(base_ref):
		ranged_attack()
