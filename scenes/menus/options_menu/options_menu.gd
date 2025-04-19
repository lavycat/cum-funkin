extends Node2D
@export var options: Array[OptionPage] = []
@onready var page_template = $PageTemplate
@onready var option_template = $OptionTemplate
@onready var psych_ui: CanvasLayer = $PsychUI
@onready var textContainer: = $PsychUI/VBoxContainer
var can_exit:bool = true
var keybinds_menu:Control = preload("res://scenes/menus/options_menu/keybinds_menu.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
var selectables:Array[Dictionary]
var cur_selected:int = 0:
	set(v):
		cur_selected = wrapi(v, 0, len(selectables))
		return v
var cur_selected_object:
	get:
		return selectables[cur_selected]['object']
var cur_selected_data:
	get:
		return selectables[cur_selected]['data']
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	psych_ui.add_child(keybinds_menu)
	keybinds_menu.visible = false
	var it = 0
	for page in options:
		var optionPage = page_template.duplicate()
		optionPage.get_child(0).text = page.page_name
		textContainer.add_child(optionPage)
		var alph:Alphabet = optionPage.get_child(0)
		alph.position.x = (1280 - alph.size.x) / 2
		for option in page.page_options:
			it+=1
			var optionObj = option_template.duplicate()
			optionObj.get_child(0).text = option.option_display_name
			if (option.option_type != 0):
				optionObj.get_child(1).text = str(SaveMan.get_data(option.option_name))
				optionObj.get_child(2).visible = false
			else:
				optionObj.get_child(2).play('selected' if SaveMan.get_data(option.option_name) != false else 'unselected')
				optionObj.get_child(1).visible = false
			var alpha:Alphabet = optionObj.get_child(1)
			alpha.position.x = (1280 - alpha.size.x) * 0.75
			textContainer.add_child(optionObj)
			optionObj.get_child(0).position.x = 1280 * 0.15
			selectables.append({'object': optionObj,'data': option})	


func change_option_value_enterical():
	if cur_selected_data.option_type == 0:
		SaveMan.set_data(cur_selected_data.option_name, !SaveMan.get_data(cur_selected_data.option_name))
		cur_selected_object.get_child(1).text = str(SaveMan.get_data(cur_selected_data.option_name))
		cur_selected_object.get_child(2).play('selected' if SaveMan.get_data(cur_selected_data.option_name) != false else 'unselected')
func change_option_value_directional(mult:int = 1):
	match cur_selected_data.option_type:
		0:
			SaveMan.set_data(cur_selected_data.option_name, !SaveMan.get_data(cur_selected_data.option_name))
			cur_selected_object.get_child(2).play('selected' if SaveMan.get_data(cur_selected_data.option_name) != false else 'unselected')
		1:
			var original_data = SaveMan.get_data(cur_selected_data.option_name)
			SaveMan.set_data(cur_selected_data.option_name, wrap(original_data + (cur_selected_data.option_number_range.step*mult), cur_selected_data.option_number_range.minimum, cur_selected_data.option_number_range.maximum))
			cur_selected_object.get_child(1).text = str(SaveMan.get_data(cur_selected_data.option_name))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed('ui_up'):
		cur_selected -= 1
		AudioManager.play_sfx(AudioManager.MENU_SCROLL)
	elif Input.is_action_just_pressed('ui_down'):
		cur_selected += 1
		AudioManager.play_sfx(AudioManager.MENU_SCROLL)
	psych_ui.offset.y = lerp(psych_ui.offset.y, -cur_selected_object.global_position.y + 360, delta * 5)
		
	var shiftMult = 5 if Input.is_key_pressed(KEY_SHIFT) else 1
	if Input.is_action_just_pressed('ui_left'):
		change_option_value_directional(-1 * shiftMult)
		AudioManager.play_sfx(AudioManager.MENU_SCROLL)
	elif Input.is_action_just_pressed('ui_right'):
		change_option_value_directional(1 * shiftMult)
		AudioManager.play_sfx(AudioManager.MENU_SCROLL)
		
	if Input.is_action_just_pressed('ui_accept'):
		change_option_value_enterical()
		AudioManager.play_sfx(AudioManager.MENU_CONFIRM)
		
	for oj in selectables:
		oj['object'].modulate.a = (1 if oj['object'] == cur_selected_object else 0.8)
	if can_exit:
		if Input.is_action_just_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			SaveMan.save_data()
			SceneManager.switch_scene("res://scenes/menus/main_menu.tscn")
	else:
		if Input.is_action_just_pressed("ui_cancel"):
			await create_tween().tween_property(keybinds_menu,"modulate:a",0.0,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).finished
			can_exit = true
			keybinds_menu.visible = false
