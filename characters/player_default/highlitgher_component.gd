extends Node
class_name PlayerHighlighter

static var highlight_sources: Dictionary = {}

var highlighted_object: Node = null


func physics_update(player: CharacterBody2D, interaction: PlayerInteraction) -> void:
	var closest_area: Area2D = null
	
	if interaction.holding:
		closest_area = interaction.get_closest_interactable_area(player, false, true)
	else:
		closest_area = interaction.get_closest_interactable_area(player, true, true)
	
	var new_object: Node = null
	
	if closest_area != null:
		new_object = closest_area.get_parent()
	
	if new_object == highlighted_object:
		return
	
	clear_highlight()
	
	if new_object != null:
		apply_highlight(new_object)


func apply_highlight(object: Node) -> void:
	highlighted_object = object
	add_highlight_source(object, self)


func clear_highlight() -> void:
	if highlighted_object != null and is_instance_valid(highlighted_object):
		remove_highlight_source(highlighted_object, self)
	
	highlighted_object = null


func add_highlight_source(object: Node, source: Node) -> void:
	if object == null or not is_instance_valid(object):
		return
	
	if not highlight_sources.has(object):
		highlight_sources[object] = []
	
	var sources: Array = highlight_sources[object]
	
	if source not in sources:
		sources.append(source)
	
	object.outlined = true


func remove_highlight_source(object: Node, source: Node) -> void:
	if object == null or not is_instance_valid(object):
		return
	
	if not highlight_sources.has(object):
		object.outlined = false
		return
	
	var sources: Array = highlight_sources[object]
	sources.erase(source)
	
	if sources.is_empty():
		highlight_sources.erase(object)
		object.outlined = false
	else:
		object.outlined = true


func _exit_tree() -> void:
	clear_highlight()
