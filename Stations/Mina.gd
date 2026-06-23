# Esse script serve para toda station que gere um item
# que precise apenas do Player (Carvao ou Ferro)

extends Node2D
class_name Mine

@onready var sprMina: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprBotao: Node2D = $Botao_Spr
@onready var area: Area2D = $Area_Mina
@onready var timer: Timer = $Producao_Timer
@onready var label: CanvasItem = $Produzindo_Label

# Tipo de Estrutura:
# 0 = Carvao
# 1 = Ferro
@export_enum("Carvao", "Ferro") var type: int

var outlined := false

var nearby_players: Array[Node] = []
var active_miners: Array[Node] = []

var ore: PackedScene
var station


func _ready() -> void:
	if type == 0:
		ore = load("res://Stations/Carvao_Minerio.tscn")
		station = load("res://Stations/placeholders/mina_carvao_ph.png")
	else:
		ore = load("res://Stations/Ferro_Minerio.tscn")
		station = load("res://Stations/placeholders/mina_ferro_ph.png")

	sprBotao.visible = false
	label.visible = false

	update_visual_state()


func _process(_delta: float) -> void:
	if outlined:
		if sprMina.animation != "outlined":
			sprMina.play("outlined")
	else:
		if sprMina.animation != "default":
			sprMina.play("default")


func start_production(player: Node) -> void:
	if player == null or not is_instance_valid(player):
		return

	# Evita que um player comece a minerar estando fora da área.
	if player not in nearby_players:
		return

	if player not in active_miners:
		active_miners.append(player)

	if timer.is_stopped():
		timer.start()

	update_visual_state()


func stop_production(player: Node) -> void:
	if player == null:
		return

	active_miners.erase(player)

	if active_miners.is_empty():
		if not timer.is_stopped():
			timer.stop()

	update_visual_state()


func force_stop_production() -> void:
	active_miners.clear()

	if not timer.is_stopped():
		timer.stop()

	update_visual_state()


func is_miner_active(player: Node) -> bool:
	return player in active_miners


func update_visual_state() -> void:
	var has_nearby_player := not nearby_players.is_empty()
	var is_producing := not active_miners.is_empty()

	if is_producing:
		sprBotao.visible = false
		label.visible = true
	else:
		label.visible = false
		sprBotao.visible = has_nearby_player


# Quando o tempo de produção terminar, spawna o item produzido
func _on_producao_timer_timeout() -> void:
	if ore == null:
		return

	var new_ore = ore.instantiate()

	get_parent().add_child(new_ore)

	new_ore.global_position = global_position + Vector2(0, -20)
	new_ore.rotation = [-3, -2, -1, 0, 1, 2, 3].pick_random()
	new_ore.z_index = 7

	# Se ninguém estiver minerando mais, garante que pare.
	if active_miners.is_empty():
		timer.stop()

	update_visual_state()


# Quando o player entra na área de atuação
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_player_body(body):
		return

	if body not in nearby_players:
		nearby_players.append(body)

	update_visual_state()


# Quando o player sai da área de atuação
func _on_area_2d_body_exited(body: Node2D) -> void:
	if not is_player_body(body):
		return

	nearby_players.erase(body)

	# Se esse player estava minerando e saiu da área,
	# remove apenas ele da lista de mineradores.
	if body in active_miners:
		stop_production(body)
	else:
		update_visual_state()


func is_player_body(body: Node) -> bool:
	return body.is_in_group("players") or body.name == "player"


func _exit_tree() -> void:
	force_stop_production()
