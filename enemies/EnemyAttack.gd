extends Node

@onready var _attack_range = $"../AttackArea"
@onready var _attack_timer = $AttackTimer

var base_in_range = false
var base_ref:StaticBody2D = null

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Base"):
		base_in_range = true
		base_ref = body
		if _attack_timer.is_stopped():
			_attack_timer.start()
	pass


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Base"):
		base_in_range = false
		base_ref = null
		_attack_timer.stop()
	pass




func _on_attack_timer_timeout() -> void:
	if base_in_range and is_instance_valid(base_ref):
		attack()
		
	pass



func attack()->void:
	var base_health:BaseHealth = base_ref.get_node("Health")
	if base_health:
		base_health.take_damage(50.0)
	pass
