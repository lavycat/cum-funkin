extends Node2D
@export var levels:Array[LevelData] = []

@onready var level_display: CanvasLayer = $level_display

var cur_selected:float = 0

func _ready() -> void:
	create_level_display()
func change_level_select(p:int):
	cur_selected = wrap(cur_selected + p,0,levels.size())
	AudioManager.play_sfx(AudioManager.MENU_SCROLL)
func load_level():
	AudioManager.play_sfx(AudioManager.MENU_CONFIRM)
	var level := levels[cur_selected]
	Game.campaign_songs = level.level_songs
	Game.level_name = level.level_name
	Game.song_name = level.level_songs[0]
	Game.song_diff = "hard"
	Game.play_mode = Game.PlayMode.CAMPAIGN
	SceneManager.switch_scene("uid://cgla7xsm2aocj")
	
func create_level_display():
	var penis:int = 1
	for i in levels:
		var spr := Sprite2D.new()
		spr.texture = i.level_image
		spr.centered = false
		spr.position.x -= spr.texture.get_width()/2
		spr.position.y += (max(110,spr.texture.get_height()) + 10) * penis
		level_display.add_child(spr)
		penis += 1

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("ui_cancel"):
		SceneManager.switch_scene("uid://dv4w8fl053lxq")
	if event.is_action_pressed("ui_down"):
		change_level_select(1)
	if event.is_action_pressed("ui_up"):
		change_level_select(-1)
	if event.is_action_pressed("ui_accept"):
		load_level()
		
func _process(delta: float) -> void:
	var COCK = level_display.get_child(cur_selected)
	level_display.offset.y = lerp(level_display.offset.y,452 - (COCK.position.y - COCK.texture.get_height()/2),10.2 * delta)
