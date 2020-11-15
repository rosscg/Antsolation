extends Label

export var value = 0
export var title = 'Speed'
export var increment = 1
export var max_val = 100
export var min_val = 0


func _ready():
	$Name.text = str(title)
	
func _process(_delta):
	self.text = str(value)


func _on_ButtonUp_button_up():
	if value + increment <= max_val:
		value += increment
		get_parent().get_parent().get_node("World").civ_stats_t1[title] = value
	
func _on_ButtonDown_button_up():
	if value - increment >= min_val:
		value -= increment
		get_parent().get_parent().get_node("World").civ_stats_t1[title] = value
