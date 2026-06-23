extends RigidBody2D
class_name Bucket


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var is_filled := false:
	set(value):
		if is_filled == value:
			return
		
		is_filled = value
		update_animation()


var outlined := false:
	set(value):
		if outlined == value:
			return
		
		outlined = value
		update_animation()


func _ready() -> void:
	update_animation()


func update_animation() -> void:
	if not is_node_ready():
		return
	
	if outlined:
		if is_filled:
			sprite.play("WaterBucketOutlined")
		else:
			sprite.play("BucketOutlined")
	else:
		if is_filled:
			sprite.play("WaterBucket")
		else:
			sprite.play("Bucket")


func get_filled() -> void:
	is_filled = true


func empty() -> void:
	is_filled = false
