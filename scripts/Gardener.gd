extends Node2D

const FoodScene = preload("res://scenes/Food.tscn")
onready var world = self.get_parent()

var time_since_spawn = 0
var food_spawn_rate = 3

func _ready():
	food_spawn_rate = food_spawn_rate# / world.speed_mod

func _process(delta):
	if time_since_spawn > food_spawn_rate:
		time_since_spawn = 0
		spawn_food()
	else:
		time_since_spawn += delta



func spawn_food():
	var food_instance = FoodScene.instance()
	food_instance.scale = Vector2(.5,.5)
	food_instance.position = world.get_random_position_untouched(36)
	world.get_node("Food").add_child(food_instance)