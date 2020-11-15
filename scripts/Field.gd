extends Label

var value = 0
export var title = 'Speed'


func _ready():
	$Name.text = str(title)
	
func _process(_delta):
	self.text = str(value)


func _on_ButtonUp_button_up():
	if get_parent().points >= 1:
		get_parent().points -= 1
		value += 1
		get_parent().get_parent().get_node('World').t1_stats_dict[title] = value/10

func _on_ButtonDown_button_up():
	if value >= 1:
		get_parent().points += 1
		value -= 1
#		get_parent().stats[title] = value/10
		get_parent().get_parent().get_node('World').t1_stats_dict[title] = value/10
