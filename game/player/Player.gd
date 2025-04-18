class_name Player extends Node
@export var notefield:NoteField
@export var does_input:bool = true
@export var autoplay:bool = false
signal notehit(player:Player,note:Note)
signal notemiss(player:Player,note:Note)
var notemiss_callback:Callable = note_miss
var notehit_callback:Callable = note_hit
var stats:PlayerStats = PlayerStats.new()
var pressed:Array[bool] = []
var keycount:int = 4
var note_actions:PackedStringArray = ["note_left","note_down","note_up","note_right"]
var id:int = -1
var chars:Array[Character] = []
## ffmpreg
func _init(_notefield:NoteField,_has_input:bool = true,_autoplay:bool = false) -> void:
	self.autoplay = _autoplay
	self.does_input = _has_input
	self.notefield = _notefield
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.resize(keycount)
	pressed.fill(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for note:Note in notefield.notes.get_children():
		if autoplay:
			if note.time < Conductor.time and not note.was_hit:
				note.was_hit = true
				notehit_callback.call(note)
				notehit.emit(self,note)
				note.sustain_ticking = true
		## dumb ass miss code :3
		if Conductor.time - (note.time) > 0.180 and not note.missed and not note.was_hit and not autoplay:
			note.missed = true
			note.sprite.modulate = Color.DIM_GRAY
			notemiss_callback.call(note)
			notemiss.emit(note)
		if note.was_hit and not note.missed:
			
			note.sprite.visible = false
			if not pressed[note.column]:
				if not note.missed:
					if note.sustain_length >= Conductor.step_crochet:
						if not autoplay:
							note.missed = true
							notemiss_callback.call(note)
							notemiss.emit(self,note)
							return
			if note.og_sustain_length > 0.0:
				note.sustain_length = (note.time + note.og_sustain_length) - Conductor.time
			else:
				note.sustain_length -= delta
			if note.sustain_ticking:
				note.sustain_tick_timer -= delta
			if note.sustain_length < 0:
				note.queue_free()
			if note.sustain_tick_timer <= 0.0:
				notehit_callback.call(note)
				notehit.emit(self,note)

			
	pass
func ev_to_dir(ev:InputEvent) -> int:
	var i = 0
	for act in note_actions:
		if ev.is_action(note_actions[i]):
			return i
		i += 1
	return -1

func _unhandled_input(event):
	var dir:int = ev_to_dir(event)
	if dir == -1 or event.is_echo() or not does_input or autoplay:
		return
	pressed[dir] = event.is_pressed()
	## note shit do later
	
	var strum = notefield.strums.get_child(dir)
	if event.is_pressed():
		if notefield:
			var hit_notes = notefield.notes.get_children()
			hit_notes = hit_notes.filter(func(n:Note): if n.can_hit and not n.too_late and not n.missed and not n.was_hit and n.column == dir: return n)
			if not hit_notes.is_empty():
				if hit_notes.size() > 1:
					var last_note = null
					for i:Note in hit_notes:
						if last_note != null:
							if abs(i.time - last_note.time) < 0.003:
								print("dumb stacks :[")
								i.was_hit = true
								notehit_callback.call(i)
								notehit.emit(self,i)
								i.sustain_ticking = true
						last_note = i
				hit_notes.front().was_hit = true
				notehit_callback.call(hit_notes.front())
				notehit.emit(self,hit_notes.front())
				hit_notes.front().sustain_ticking = true
		if not strum.animation.contains("confirm"): 
			notefield.strums.get_child(dir).play_anim(Strum.PRESSED)
	else:
		notefield.strums.get_child(dir).play_anim(Strum.STATIC)
func note_miss(note:Note):
	
	stats.combo = 0
	stats.health -= 0.05/(1.0 + note.sustain_length)
	stats.combo_breaks += 1
	for i in chars:
		i.sing(note.column,"_miss")
	if Game.instance.hud:
		Game.instance.hud.on_note_miss(self,note)
	print("missed a note")
func note_hit(note:Note,cheat:bool = false):
	var strum:Strum = note.notefield.strums.get_child(note.column)
	
	if not note.sustain_ticking:
		
		var rating:NoteRating = NoteRating.rate_note(note,autoplay or cheat)
		if rating.rating != "invalid":
			stats.ratings[rating.rating] += 1
		strum.material = note.material.duplicate(false)
		stats.combo += 1
		stats.notes_hit += 1
		stats.health += 0.02
		stats.score += rating.score
		match rating.rating.to_lower():
			"sick","marvelous":
				stats.accuracy_points += 1.0
				notefield.im_splashing_it(note.column)
			"good":
				stats.accuracy_points += 0.67
			"bad":
				stats.accuracy_points += 0.34
			_:
				pass
		stats.accuracy = stats.accuracy_points / (stats.notes_hit + stats.combo_breaks)
				
		if Game.instance:
			Game.instance.hud.on_note_rate(self,rating)
	else:
		stats.health += 0.004
			
	if not note.sustain_ticking:
		if note.og_sustain_length > 0.0:
			note.og_sustain_length -= (Conductor.time - note.time)
			note.sustain_length = note.og_sustain_length
			
	note.sustain_tick_timer = Conductor.step_crochet
	
	strum.play_anim(Strum.CONFIRM,true)
	if not strum.animation_finished.is_connected(strum.play_anim.bind(0)):
		strum.animation_finished.connect(strum.play_anim.bind(0),CONNECT_ONE_SHOT)
		
		
	for i in chars:
		i.sing(note.column)
	if Game.instance.hud:
		Game.instance.hud.on_note_hit(self,note)
		
func rating_shit(hit_time:float):
	pass
