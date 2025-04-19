class_name PageOption extends Resource
enum OptionType{
	BOOL = 0,
	INT = 1,
	FLOAT = 2,
	MULTI_CHOICE = 3,
}
@export var option_type:OptionType = 0
@export var option_name:StringName = "example_option"
@export var option_display_name:StringName = "example_option"
@export var option_number_range:OptionRange = OptionRange.new()
@export var option_choices:Array[String] = []
@export_custom(PROPERTY_HINT_FILE,".png") var p
