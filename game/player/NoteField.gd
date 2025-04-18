class_name NoteField extends Node2D
var note_data:Array[NoteData] = []:
	set(v):
		note_data = v
		note_data = note_data.filter(func(a): if a.player%Game.meta.players.size() == self.player.id: return a)
		note_data.sort_custom(func(a,b): return a.time < b.time)
var notes:Node2D = Node2D.new()
var splashe_group:Node2D = Node2D.new()
var splashs:Array[AnimatedSprite2D] = []
func im_splashing_it(splash_index:int):
	var splash = splashs[splash_index]
	splash.visible = true
	splash.frame = 0
	splash.play("note splash %s"%[Strum.column_to_str(splash_index)])
	await splash.animation_finished
	splash.visible = false
	
@export var player:Player = null
var strums:Node2D
var temp_note = load("res://scenes/notes/normal.tscn")
var strumline:PackedScene = null
# Called when the node enters the scene tree for the first time.
func init_splashes():
	for i in player.keycount:
		var skin = Game.instance.hud.skin
		var splash:AnimatedSprite2D = AnimatedSprite2D.new()
		splash.sprite_frames = skin.noteskin_splash_frames
		splash.scale = Vector2(skin.noteskin_splash_scale,skin.noteskin_splash_scale)
		splashe_group.add_child(splash)
		splash.global_position = strums.get_child(i).global_position
		splashs.append(splash)
		splash.visible = false
		
		
func _ready():
	if SaveMan.get_data("downscroll",false):
		position.y = 720 - position.y
#region gen_strums
	add_child(strums)
	add_child(notes)
	add_child(splashe_group)
	init_splashes()
	
#endregion

var note_index:int = 0
var note_spawn_distance:float = 1.5
#var note_spawn_distance:float = 1000.0

func queue_notes():
		
	for i in range(note_index,note_data.size()):
		var data = note_data[i]
		var scrollspeed = Game.chart.scroll_speed if SaveMan.get_data("scroll_speed",1.0) == 1.0 else SaveMan.get_data("scroll_speed",1.0)
		var down_scroll_mult = 1.0 if not SaveMan.get_data("downscroll",false) else -1.0
		if data.time > Conductor.time + (note_spawn_distance/(scrollspeed/Conductor.rate)):
			break
		var hudskin = Game.instance.hud.skin
		var note:Note = temp_note.instantiate()
		note.scale = Vector2(hudskin.noteskin_scale,hudskin.noteskin_scale)
		note.column = data.column
		note.time = data.time
		note.sustain_length = max(data.length,0.0)
		note.og_sustain_length = max(data.length,0.0)
		note.scroll_speed = scrollspeed
		note.notefield = self
		notes.add_child(note)
		note.material.set_shader_parameter("note_color",note.note_colors[note.column%4])
		note.sprite.play(Strum.column_to_str(note.column))
		note.global_position.x = strums.get_child(note.column).global_position.x
		## sustain code by sword cube thx :3
		var distance: float = (450 * note.sustain_length) * (note.scroll_speed / Conductor.rate)
		var scale_shit: float = (note.scale.y / pow(scale.y,2.0))
		var tail_offset: float = note.tail.get_rect().size.y / 2.0
		var tail_distance: float = (tail_offset * down_scroll_mult)
		note.sustain.points[1].y = (((distance * down_scroll_mult) / scale_shit - tail_distance))
		note.tail.position = note.sustain.get_point_position(1) + Vector2(0,tail_offset)*down_scroll_mult
		if down_scroll_mult == -1:
			note.tail.flip_v = true
		note_index += 1
		
func _process(delta):
	queue_notes()
	
	var down_scroll_mult = 1.0 if not SaveMan.get_data("downscroll",false) else -1.0
	
	for note:Note in notes.get_children():
		var strum = strums.get_child(note.column)
		if note.too_late:
			note.missed = true
			note.queue_free()
			
		#note.global_position.y = (strum.global_position.y) - (450 * (Conductor.time - (note.time + (note.og_sustain_length - note.sustain_length)))) * (note.scroll_speed/Conductor.rate) * scale.y * down_scroll_mult
		var note_pos = (450 * (Conductor.play_head - (note.time + (note.og_sustain_length - note.sustain_length))))
		var note_transform = (note.scroll_speed/Conductor.rate) * scale.y * (down_scroll_mult * -1.0)
		note.position.y = note_pos * note_transform
		if note.was_hit:
			note.position.y = 0
			var distance: float = (450 * note.sustain_length) * (note.scroll_speed / Conductor.rate)
			var scale_shit: float = (note.scale.y / pow(scale.y,2.0))
			var tail_offset: float = note.tail.get_rect().size.y / 2.0
			var tail_distance: float = (tail_offset * down_scroll_mult)
			note.sustain.points[1].y = ((distance * down_scroll_mult) / scale_shit - tail_distance)
			
			note.tail.position = (note.sustain.get_point_position(1)) + Vector2(0,tail_offset)*down_scroll_mult
		if note.missed:
			note.position.y = strum.position.y - (450 * (Conductor.play_head - (note.time + (note.og_sustain_length - note.sustain_length)))) * (note.scroll_speed/Conductor.rate) * down_scroll_mult
	
