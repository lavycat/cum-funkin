class_name Game extends Node2D
static var meta:ChartMeta
static var chart:Chart = null
static var play_mode:PlayMode = 0
static var campaign_song:int = 0
static var campaign_songs:PackedStringArray = []

static var level_score:int
static var level_cbs:int
static var level_acc:float = 0.0
static var level_name:String = ""
static var instance:Game = null
@onready var ui_layer = $"UI Layer"
@onready var tracks = $tracks
@onready var event_manager: EventHandler = %event_manager
@onready var hud: BaseHud = $"UI Layer/HUD"
var song_player:AudioStreamPlayer = null ## is set on play music shit
static var song_name:String = "dad-battle"
static var song_diff:String = "hard"

var stage:Stage = null
var song_script_objs:Array[Object] = []
var player_list:Array[Player] = []


var player_field:Player = null
var cpu_field:Player = null
static var shaders:bool = true
var song_started:bool = false
enum PlayMode {
	FREEPLAY = 0,
	CAMPAIGN = 1
}
func beat_hit(beat:int):
	if beat %4 == 0 and !died and beat != 0:
		hud.scale += Vector2(0.05,0.05)
		stage.camera.zoom += Vector2(0.03,0.03)
	hud.on_beat_hit(beat)
func step_hit(step:int):
	pass
static func load_meta(song_name:String) -> ChartMeta:
	var meta_path:String = "res://assets/songs/%s/meta.tres"%song_name
	print(meta_path)
	if ResourceLoader.exists(meta_path):
		return ResourceLoader.load(meta_path,"",ResourceLoader.CACHE_MODE_IGNORE)
	else:
		return ChartMeta.new()
		
func _enter_tree() -> void:
	meta = load_meta(song_name)
	chart = Chart.load_chart(song_name,song_diff)
	for i:Script in meta.song_scripts:
		var obj = i.new()
		song_script_objs.append(obj)
func _ready():
	instance = self
	Conductor.reset()
	
	
	#region music shits
	var player:AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = AudioStreamSynchronized.new()
	player.stream.stream_count = 1 + Game.meta.voices.size()
	player.bus = "music"
	player.stream.set_sync_stream(0,meta.inst)
	Conductor.audio = player
	tracks.add_child(player)
	var s = 0
	for i in Game.meta.voices:
		player.stream.set_sync_stream(s+1,i)
		s += 1
	song_player = player
	song_player.finished.connect(end_song)
	Conductor.audio.pitch_scale = Conductor.rate
#endregion
	event_manager.events = meta.events + chart.events
	for i in event_manager.events:
		i._ready()
	event_manager.events.sort_custom(func(a,b): return a.time < b.time)
	Conductor.beat_hit.connect(beat_hit)
	Conductor.step_hit.connect(step_hit)
	
	hud.queue_free()
	
	hud = meta.hud.instantiate()
	hud.skin = meta.ui_skin
	for i in meta.players.size():
		var config:PlayerConfig = meta.players[i]
		
		var nfield:NoteField = NoteField.new()
		nfield.global_position.y = 100
		
		const strum_offset = 160*0.7
		print(hud.size.x)

		
		
		nfield.strums = load("res://scenes/strumlines/normal.tscn").instantiate()
		hud.add_child(nfield)
		var pler:Player = Player.new(nfield,config.has_input,config.autoplay)
		if SaveMan.get_data("opponent_play"):
			pler.does_input = not pler.does_input
			pler.autoplay = not pler.autoplay
			
		pler.id = i
		nfield.player = pler
		nfield.note_data = chart.notes.duplicate()
		nfield.global_position.x = 640 + 35 - 250
		nfield.global_position.x += 310 if nfield.player.does_input else -320

		player_list.append(pler)

		if pler.does_input:
			hud.stats = pler.stats
		hud.add_child(pler)
		if hud:
			hud.pivot_offset = hud.size / 2.0
	for i in chart.bpms:
		Conductor.queue_bpm_change(i)
	Conductor.bpm = chart.bpms[0].bpm
	meta.events.sort_custom(func(a,b): return a.time < b.time)
	var cool_players = player_list.filter(func(p:Player): return p.does_input)
	## it is possible for you to make more than 1 player with input, thats just dumb
	var p = cool_players.front()
	if SaveMan.save.autoplay:
		p.autoplay = true
	if SaveMan.save.center_notefield:
		for i in player_list:
			i.notefield.visible = false
		p.notefield.visible = true
		p.notefield.position.x = 640 - (160*0.7)*2.0
			
	

	instance = self
#region stage shits
	if !meta.stage.can_instantiate():
		var col = ColorRect.new()
		col.size = Vector2(1920,1080)
		col.color = Color.BLACK
		chart.meta.stage.pack(col)
	stage = meta.stage.instantiate()
	add_child(stage,true,Node.INTERNAL_MODE_FRONT)
#endregion
#region character shits
	if meta.player_character:
		if meta.player_character.can_instantiate():
			var bf:Character = meta.player_character.instantiate()
			bf.position = stage.player.position
			stage.add_child(bf)
			player_list[1].chars.append(bf)
			
	if meta.cpu_character:
		if meta.cpu_character.can_instantiate():
			var dad = meta.cpu_character.instantiate()
			dad.position = stage.cpu.position
			stage.add_child(dad)
			player_list[0].chars.append(dad)

#endregion

	ui_layer.add_child(hud)
	meta = null
	
#region song scripts shits
	for obj:Object in song_script_objs:
		if obj is Node:
			add_child(obj)
	#endregion
var last_stream_time:float = 0.0
var cur_event:int = 0
var song_time:float
var died:bool = false
func die():
	if died:
		return
	player_list[1].stats.health = 0.0
func _process(delta):
	stage.camera.zoom = lerp(stage.camera.zoom,Vector2(stage.zoom,stage.zoom),5*delta)
	hud.scale = lerp(hud.scale,Vector2.ONE,5*delta)
	
	if hud.stats.health <= 0.0 and !died:
			died = true
			event_manager.process_mode = Node.PROCESS_MODE_DISABLED
			var death_char = player_list[1].chars[0].death_character.instantiate()
			death_char.global_position = player_list[1].chars[0].global_position
			stage.visible = false
			add_child(death_char)
			stage.camera.position = death_char.camera_position.global_position
			song_player.stop()
			Conductor.audio = death_char.music
			create_tween().tween_property(hud,"modulate:a",0,0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
			for i in player_list:
				i.queue_free()
	song_time = Conductor.audio.get_playback_position()
	#if Conductor.last_time == song_time or not song_started:
		#Conductor.time += delta
	#else:
		#Conductor.time = song_time
		#Conductor.last_time = song_time
	if Conductor.time >= 0.0 and not song_started:
		song_started = true
		Conductor.audio.play()
		hud.call("on_song_start")
func end_song():
	await RenderingServer.frame_post_draw
	## unload cus erm sigma
	chart = null
	meta = null
	var stats = hud.stats
	HighScore.add_score(song_name,song_diff,[stats.score,stats.combo_breaks,stats.accuracy])
	Conductor.reset()
	match play_mode:
		PlayMode.FREEPLAY:
			SceneManager.switch_scene("uid://q6e1kix7o3h5")
		PlayMode.CAMPAIGN:
			if campaign_song != campaign_songs.size()-1:
				level_acc += hud.stats.accuracy
				level_score += hud.stats.score
				level_cbs += hud.stats.combo_breaks
				campaign_song += 1
				song_name = campaign_songs[campaign_song]
				get_tree().reload_current_scene()
			else:
				HighScore.add_level_score(level_name,song_diff,[level_score,level_cbs,level_acc/campaign_song + 1])
				print(HighScore.level_scores.get(level_name))
				campaign_song = 0
				campaign_songs = []
				level_acc = 0
				level_cbs = 0
				level_score = 0
				SceneManager.switch_scene("res://scenes/menus/main_menu.tscn")
			
			
var paused:bool = false
func _input(event):
	if event.is_pressed() and !event.is_echo() and !died:
		if event.is_action_pressed("ui_accept") and not paused:
			paused = true
			var pause = load("uid://b1tbvav234cyf").instantiate()
			add_child(pause,true)
			Game.instance.process_mode = Node.PROCESS_MODE_DISABLED
	if event is InputEventKey:
			
		if event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_F7:
				die()
			if event.keycode == KEY_F3:
				skip_time(Conductor.time + 30.0)
			if event.keycode == KEY_F5:
				if not event.is_echo():
					if event.is_pressed():
						meta = load_meta(chart.song_name)
						Conductor.audio.stop()
						Conductor.reset() 
						get_tree().unload_current_scene()
						SceneManager.switch_scene("res://scenes/gmae.tscn")
						
						
	
func _exit_tree() -> void:
	for i:Object in song_script_objs:
		if is_instance_valid(i):
			i.free()
		
func skip_time(time_to:float):
	for i in player_list:
		time_to = min(time_to,Conductor.audio.stream.get_length() - 0.001)
		song_player.seek(time_to)
		Conductor.time = time_to
		print(time_to)
		i.notefield.queue_notes()
		if not i.autoplay:
			for n:Note in i.notefield.notes.get_children():
				if (n.time) - Conductor.time < n.og_sustain_length + 2.2:
					i.note_hit(n,true)
					n.free()
