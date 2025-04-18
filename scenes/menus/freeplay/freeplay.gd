extends Node2D

@onready var temp_item: Node2D = $temp_item
@export var freeplay_list:Array[FreeplayData] = []
@onready var menu_bg: Sprite2D = $CanvasLayer/menu_bg
@onready var camera: Camera2D = $Camera

var items:Array[Node2D] = []
var cur_item:int = 0:
	set(v):
		cur_item = wrapi(v,0,freeplay_list.size())
var cur_diff_str:String = "hard"
@onready var score: Label = $ui/PanelContainer/VBoxContainer/score

@onready var diff_label: Label = $ui/PanelContainer/VBoxContainer/diff
@onready var rate_label: Label = $ui/PanelContainer/VBoxContainer/rate
static var rate:float = 1.0
var cur_rate:float = 1.0:
	set(v):
		cur_rate = v
		rate_label.text = "rate: %0.1f"%cur_rate
		Conductor.rate = cur_rate
var cur_diff:int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.position.x = 640
	var count:int = 0
	for i:FreeplayData in freeplay_list:
		if i == null:
			i = FreeplayData.new()
		var item:Node2D = temp_item.duplicate()
		var item_icon:Sprite2D = item.get_node("icon")
		var item_label:Alphabet = item.get_node("song_name")
		item_label.position.x = 0
		item.position.x = 90 / 2
		item.position.y = 320
		
		item.position.y += 120 * 1.3 *count
		item_icon.texture = i.icon_texture
		item_icon.hframes = i.icon_frames
		item_label.text = i.song_name
		
		if not i.display_name.is_empty():
			item_label.text = i.display_name
		item_icon.position.x = item_label.size.x*1.15
		item_icon.position.y += 40
		add_child(item)
		items.append(item)
		count += 1
	temp_item.queue_free()
	change_item(0)
	cur_rate = rate
	pass # Replace with function body.
var song_loaded:bool = false
var song_loading:bool = false
var song_score:int = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var song_name = freeplay_list[cur_item].song_name
	var song_diffs = freeplay_list[cur_item].difficultys
	var song_diff = song_diffs[cur_diff]
	var true_score = HighScore.get_score(song_name,song_diff)[0]
	song_score = lerp(true_score,song_score,exp(-delta*24))
	# dumb fix
	if abs(song_score - true_score) <= 100:
		song_score = true_score
	score.text = "score: %d"%song_score
	if song_loaded:
		SceneManager.switch_scene("res://scenes/gmae.tscn")
		Conductor.rate = cur_rate
	menu_bg.modulate = lerp(menu_bg.modulate,freeplay_list[cur_item].bg_color,delta*5.0)


		
	pass
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		change_item(1)
	if event.is_action_pressed("ui_up"):
		change_item(-1)
	## diff
	if event.is_action("ui_left"):
		if event is InputEventKey:
			if event.shift_pressed:
				cur_rate -= 0.1
			else:
				change_diff(-1)
	if event.is_action("ui_right"):
		if event.shift_pressed:
				cur_rate += 0.1
				
		else:
			change_diff(1)
	if event.is_action_pressed("ui_accept"):
		select_song()
	if event.is_action_pressed("ui_cancel"):
		SceneManager.switch_scene("res://scenes/menus/main_menu.tscn")
func change_item(i:int):
	if song_loading : return
	AudioManager.play_sfx(AudioManager.MENU_SCROLL)
	cur_item += i
	camera.position.y = items[cur_item].position.y
	
	
	var diffs = freeplay_list[cur_item].difficultys
	
	if diffs.has(cur_diff_str):
		cur_diff = diffs.find(cur_diff_str)
	change_diff(0)
func load_song(song_name:String):
	Game.song_name = song_name
	Game.song_diff = freeplay_list[cur_item].difficultys[cur_diff]
	SceneManager.switch_scene("res://scenes/gmae.tscn")
	
	song_loaded = true
func select_song():
	if song_loading : return
	song_loading = true
	var song_name = freeplay_list[cur_item].song_name
	load_song(song_name)
	pass
	
func change_diff(i:int = 0):
	if song_loading : return
	var diffs = freeplay_list[cur_item].difficultys
	
	cur_diff = wrapi(cur_diff + i,0,diffs.size())

	cur_diff_str = freeplay_list[cur_item].difficultys[cur_diff]
	diff_label.text = "< %s >"%cur_diff_str
