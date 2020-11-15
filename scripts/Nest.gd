extends Area2D

const AntScene = preload("res://scenes/Ant.tscn")
onready var world = self.get_parent().get_parent()

var time_since_spawn = 0
var ten_second = 0
var one_minute = 0

var team = 1
var food = 0
var nest_age = 0
var nest_maturity = 3

export var ant_cost = 10
export var queen_cost = 40
export var ant_spawn_rate = 10


func _ready():
	$ColorRect.color = world.TEAM_COLS[self.team]
	$Polygon2D.color = world.TEAM_COLS[self.team]
	ant_spawn_rate = ant_spawn_rate / world.speed_mod
	self.nest_birthday()


func _process(delta):
	$FoodLabel.text = 'Food: ' + str(food)
	
	var ant_count
	var civ_stats
	if self.team == 1:
		civ_stats = world.civ_stats_t1
		ant_count = world.ants_t1
	else:
		civ_stats = world.civ_stats_t2
		ant_count = world.ants_t2
	
	# Spawn ant
	if (ant_count == 0 or time_since_spawn > ant_spawn_rate) and \
			food >= (queen_cost if 
				(world.breeding_season and nest_age > nest_maturity and 
					ant_count >= civ_stats["Courtiers"]
				) else ant_cost):
		time_since_spawn = 0
		spawn_ant(world.breeding_season)
	else:
		time_since_spawn += delta * world.speed_mod

	# Periodic food
	if ten_second >= 10:
		food += 1
		ten_second = 0
	else:
		ten_second += delta * world.speed_mod

	if one_minute >= 60:
		nest_birthday()
		one_minute = 0
	else:
		one_minute += delta * world.speed_mod
		

func nest_birthday():
	nest_age += 1
	$Layers
	$Layers/layer1.visible = true
	$Layers/layer2.visible = true
	$Layers/layer3.visible = false
	$Layers/layer4.visible = false
	$Polygon2D.position.x = 12
	if nest_age > 1:
		$Layers/layer3.visible = true
		$Polygon2D.position.x = 16
	if nest_age > 2:
		$Layers/layer4.visible = true
		$Polygon2D.position.x = 22
	

func _on_Nest_body_entered(body):
	if body.get_parent().name == 'Ants':
		body.set_dropoff(self)



func spawn_ant(queen=false):
	queen = queen and nest_age >= nest_maturity and self.food >= queen_cost
	var ant_instance = AntScene.instance()
	ant_instance.init(team, queen, self.position)
	ant_instance.scale = Vector2(0.3,0.3)
	var stats
	if self.team == 1:
		stats = world.t1_stats_dict
	else:
		stats = world.t2_stats_dict
	ant_instance.speed += ant_instance.speed * stats['Speed']
	ant_instance.rotation_speed += ant_instance.rotation_speed * stats['Speed']
	ant_instance.vision_range += ant_instance.vision_range * stats['Vision']
	ant_instance.damage += ant_instance.damage * stats['Damage']
	ant_instance.health += ant_instance.health * stats['Health']
	ant_instance.food_capacity += ant_instance.food_capacity * stats['Carrying']
	ant_instance.lifespan += ant_instance.lifespan * stats['Lifespan']
	ant_instance.scout_range += ant_instance.scout_range * stats['Scouting']
	ant_instance.aggressiveness += ant_instance.aggressiveness * stats['Aggressive']
	world.get_node("Ants").add_child(ant_instance)
	
	if queen:
		self.food -= queen_cost
	else:
		self.food -= ant_cost