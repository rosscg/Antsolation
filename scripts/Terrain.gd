extends StaticBody2D

var types = ['tree', 'rock', 'bush']
export var type = 'tree'

func init(type=null):
	if not type:
		type = types[randi()%len(types)]
	self.type = type
	var i = randi()%3 + 1
	var texture = load("res://assets/" + type + str(i) + ".png")
	$Sprite.texture=texture
	$Sprite.position.y = -texture.get_height()/2
	
	var shape = CapsuleShape2D.new()
	shape.height = texture.get_width() - 20
	shape.radius = 10
	if type == 'tree':
		shape.height = 15
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position.y = -9


func _ready():
	self.init(self.type)
		