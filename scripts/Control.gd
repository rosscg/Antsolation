extends Control

var points = 10

#var stats = {'Speed': 0, 'Vision': 0, 'Damage':0, 'Health':0,
#				'Carrying':0, 'Lifespan':0, 'Scouting':0, 'Aggressive':0}

func _process(_delta):
	$Label.text = str(points)


func _on_Button_button_up():
	self.visible = !self.visible
	get_parent().get_node('Button').text = 'X' if self.visible else 'O'
