@tool
class_name Alphabet extends Control
@export var frames:SpriteFrames = preload("res://assets/freeplay/alphabet.res")
@export_multiline var text:String = "":
	set(v):
		text = v
		generate_sprites()
@export var bold:bool = false:
	set(v):
		bold = v
		generate_sprites(false)
var letters:Array[AnimatedSprite2D] = []
var width
func is_upper_str(str:String):
	return str.to_lower() != str
func is_alpha(str:String):
	var alphabet:String = "abcdefghijklmnopqrstuvwxyzáàãâéèêíìĩîóòõôúùũûçñýỳŷỹÿøž"
	for i in alphabet:
		if str.to_lower() == i:
			return true
	return false
func get_letter_anim(letter:String):
	var anim_name:String = letter.to_lower()
	if !bold:
		if is_alpha(letter):
			anim_name += " uppercase" if is_upper_str(letter) else " lowercase"
		else:
			anim_name += " normal"
	else:
		anim_name += " bold"
	anim_name += " instance 1"
	return anim_name
func generate_sprites(text_changed:bool = true):
	for i in get_children():
		i.queue_free()
	letters.clear()
	var DICK:int = 0
	var ROWS:int = 0
	var _width:float = 0
	for i in text:
		var letter:AnimatedSprite2D = AnimatedSprite2D.new()
		var anim_name:String = i.to_lower()
		anim_name = get_letter_anim(i)
		if i == " ":
			letter.queue_free()
			_width += 28
			continue
		if i == "\n":
			letter.queue_free()
			ROWS += 1
			DICK = 0
			continue
		if !frames.has_animation(anim_name): continue
			
		letter.sprite_frames = frames
		var letter_offset:int = 0
		print(i)
			
		size.y = max(size.y,frames.get_frame_texture(letter.animation,0).get_height())
		_width += 54
		letter.offset.x = letter_offset
		letter.position.x += _width
		letter.position.y += 56 * ROWS
		letter.position.y += size.y / 2
		letter.position.x -= 30
		add_child(letter)
		letter.play(anim_name)
		letters.append(letter)
		DICK += 1
	width = _width
	size.x = width
