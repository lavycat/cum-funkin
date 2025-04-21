extends Node2D
@onready var menu_confrim: AudioStreamPlayer = $menu_confrim
@onready var menu_scroll: AudioStreamPlayer = $menu_scroll
@onready var menu_bg_desat: Sprite2D = $Parallax2D/MenuBg_desat
@onready var items: Parallax2D = $items
## timers
@onready var desat_flicker_timer: Timer = $desat_flicker_timer
@onready var menu_item_flicker_timer: Timer = $menu_item_flicker_timer

@onready var camera: Camera2D = $Camera2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var cur_item:AnimatedSprite2D = null
var cur_selected:int = 0:
	set(v):
		cur_selected = wrap(v,0,items.get_child_count())
var options:Array[String] = ["storymode","freeplay","options"]
var selecting_something:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_item(0)
	camera.align()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.switch_scene("res://scenes/menus/titlescreen.tscn")
	if Input.is_action_just_pressed("ui_down"):
		change_item(1)
	if Input.is_action_just_pressed("ui_up"):
		change_item(-1)
		pass
	if Input.is_action_just_pressed("ui_accept") and not selecting_something:
		select_item()
		
	pass
func desat_flicker():
	desat_flicker_timer.timeout.connect(desat_flicker,CONNECT_ONE_SHOT)
	menu_bg_desat.visible = not menu_bg_desat.visible
	desat_flicker_timer.start(0.15)
	
func item_flicker():
	menu_item_flicker_timer.timeout.connect(item_flicker,CONNECT_ONE_SHOT)
	cur_item.visible = not cur_item.visible
	menu_item_flicker_timer.start(0.06)
	
func select_item():
	AudioManager.play_sfx(AudioManager.MENU_CONFIRM)
	selecting_something = true
	desat_flicker()
	item_flicker()
	for q in items.get_child_count():
		if q != cur_selected:
			var it:AnimatedSprite2D = items.get_child(q)
			create_tween().tween_property(it,"modulate:a",0.0,0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	## dumb code up ahead
	
	await get_tree().create_timer(1.0,false).timeout
	match options[cur_selected]:
		"storymode":
			SceneManager.switch_scene("uid://4lpp8setrtow")
		"freeplay":
			SceneManager.switch_scene("uid://q6e1kix7o3h5")
		"options":
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			SceneManager.switch_scene("uid://b8235xq70y2ii")
		_:
			get_tree().reload_current_scene()
			
func change_item(c:int = 0):
	cur_selected += c
	AudioManager.play_sfx(AudioManager.MENU_SCROLL)

	for i in items.get_child_count():
		var it = items.get_child(i)
		it.frame = 0
		it.play("basic")
		if cur_selected == i:
			cur_item = it
			camera.position = it.position
			it.play("white")
