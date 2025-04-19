extends Node2D

@onready var icon = $Icon
@onready var logo: AnimatedSprite2D = $logo

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	Conductor.beat_hit.connect(beat)
	Conductor.reset()
	

func _process(delta):
	Conductor.time += delta
	
func beat(b):
	logo.play("logo bumpin")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		SceneManager.switch_scene("res://scenes/menus/main_menu.tscn")
		
