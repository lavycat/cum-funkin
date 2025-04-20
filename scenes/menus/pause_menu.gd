extends CanvasLayer
@onready var bg: ColorRect = $bg
var game:Game
var cur_selected:float = 0
@onready var the_box: VBoxContainer = $"THE BOX"

const LERP_SPEED:float = 9.6
@export var items:Array[String] = []
var max_items:int = 0
var options_menu:Node2D = preload("uid://b8235xq70y2ii").instantiate()
@onready var options_layer: CanvasLayer = $options_layer


var take_input:bool = true:
	set(v):
		take_input = v
		print("INPUT TAKE CHANGED")
func _ready() -> void:
	game = Game.instance
	bg.modulate = 0
	create_tween().tween_property(bg,"modulate:a",0.6,0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	game.set_process_input(false)
	for i in items:
		var aplha = Alphabet.new()
		aplha.bold = true
		aplha.text = i
		the_box.add_child(aplha)
		the_box.position.y += 156
	change_item()
	max_items = the_box.get_child_count()
func change_item(p:int = 0):
	if p != 0:
		AudioManager.play_sfx(AudioManager.MENU_SCROLL)
	cur_selected = wrap(cur_selected + p,0,max_items)
func _input(event: InputEvent) -> void:
	if !take_input:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("ui_down"):
		change_item(1)
	if event.is_action_pressed("ui_up"):
		change_item(-1)
	
	if event.is_action_pressed("ui_accept"):
		var cockpenis:String = items[cur_selected]
		match cockpenis:
			"resume":
				game.process_mode = Node.PROCESS_MODE_INHERIT
				queue_free()
				game.set_process_input(true)
				game.paused = false
			"restart":
				SceneManager.switch_scene("uid://cgla7xsm2aocj")
			"options":
				set_process_input(false)
				var root = get_tree().root
				options_layer.reparent(root,true)
				
				game.hud.visible = false
				options_menu.is_pause = true
				options_menu.position.y = -720
				#create_tween().tween_property(options_layer,"offset:y",0,0.67)
				await RenderingServer.frame_post_draw
				options_layer.add_child(options_menu)
				visible = false
				await options_menu.exit
				options_layer.remove_child(options_menu)
				set_process_input(true)
				game.hud.visible = true
				visible = true
				take_input = true
			"exit":
				SceneManager.switch_scene("uid://dv4w8fl053lxq")
			_:
				pass

		
func _process(delta: float) -> void:
	the_box.position.y = lerp(the_box.position.y,320 + (cur_selected * -156),(LERP_SPEED) * delta)
	if !take_input:
		take_input = options_menu.is_pause

func _exit_tree() -> void:
	options_layer.queue_free()
