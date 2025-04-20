extends Node2D
signal measure_hit(measure:int)
signal beat_hit(beat:int)
signal step_hit(step:int)
		
var rate:float = 1.0:
	set(v):
		rate = max(v,0.01)
		Engine.time_scale = rate
		if audio != null:
			audio.pitch_scale = rate

var freeze_playhead:bool = false

var audio:AudioStreamPlayer = null
# bpm change balls
var bpm_changes:Array[BpmChangeEvent] = []:
	set(v):
		bpm_changes = v
var play_head:float = 0.0
var time:float = 0.0:
	set(v):
		last_time = time
		time = v
var penis_head:float = 0.0
var last_time:float = 0.0
# beat shit
var bpm:float = 100.0
var beat_crochet:float:
	get:
		return 60.0/bpm
var step_crochet:float:
	get:
		return 15.0/bpm
var measure:float = 0.0
var beat:float = 0.0
var step:float = 0.0

var measurei:int:
	get:
		return floor(measure)
var beati:int:
	get:
		return floor(beat)
var stepi:int:
	get:
		return floor(step)
var _last_change:BpmChangeEvent = BpmChangeEvent.new()
func queue_bpm_change(change_event:BpmChangeEvent):
	if not bpm_changes.has(change_event):
		bpm_changes.append(change_event)
		bpm_changes.sort_custom(func(a,b): a.time < b.time)

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in bpm_changes:
		if time > i.time and _last_change != i:
			_last_change = i
			bpm = i.bpm
			continue
	if audio and !audio.stream_paused:

		if time == last_time:
			time += delta
		else:
			time = audio.get_playback_position()
		while time < last_time:
			time = last_time
		if !freeze_playhead:
			play_head = time
	update(delta)
func update(delta:float):
		
	var last_step = step
	var last_beat = beat
	## fall back shit ig
	if bpm_changes.size() < 1:
		_last_change = BpmChangeEvent.new(0.0,bpm,0.0)
	beat = _last_change.step/4.0 + ((time - _last_change.time)/beat_crochet)
	step = _last_change.step + ((time - _last_change.time)/step_crochet)
	## some of this code i dont know how it works and i made it sorry :[
	if floori(step) > floori(last_step):
		for i in range(last_step + 1, step + 1):
			step_hit.emit(floori(i))
	if floori(beat) > floori(last_beat):
		for i in range(last_beat + 1, beat + 1):
				beat_hit.emit(floori(i))
func reset():
	bpm_changes.clear()
	time = 0.0
	last_time = 0
	play_head = 0
	bpm = 100.0
	beat = 0.0
	step = 0.0
